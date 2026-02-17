# Detailed Plan: Full Async/Await Migration (Option 3)

## Executive Summary

Migrate the Experiment iOS Client from GCD-based concurrency to Swift's native async/await while maintaining 100% backward compatibility with existing APIs. This will provide a modern, type-safe concurrency model while allowing incremental adoption by users.

---

## 1. Current State Analysis

### GCD Usage Patterns
```swift
// Current pattern
fetchQueue.async {
    // work
    completion?(result)
}

// 8+ DispatchQueues:
- fetchQueue: Serial queue for fetch operations
- flagsQueue: Serial queue for flag updates
- userQueue: Serial queue for user management
- variantsStorageQueue: Concurrent queue with barriers
- flagsStorageQueue: Concurrent queue with barriers
- exposureQueue: Serial queue for exposure tracking
- pollerQueue: Serial queue for polling
- backoff queues: Multiple queues in Backoff class
```

### Completion Handler Patterns
```swift
// Non-throwing completion
completion: ((ExperimentClient, Error?) -> Void)?

// Throwing-style completion
completion: ((Error?) -> Void)?

// Result-based internal
completion: (Result<T, Error>) -> Void
```

### @objc Constraints
- Protocol must remain @objc for Objective-C compatibility
- Cannot add async methods directly to @objc protocols
- Need separate Swift-only protocol or extension

---

## 2. Migration Strategy

### Phase-Based Approach

**Phase 1: Foundation (Weeks 1-2)**
- Add async/await infrastructure
- Create bridging layer between GCD and async/await
- Add new async protocol without breaking existing

**Phase 2: Core APIs (Weeks 3-4)**
- Implement async versions of main methods
- Migrate internal implementation to async/await
- Keep completion-based versions working

**Phase 3: Actor Migration (Weeks 5-6)**
- Convert appropriate classes to actors
- Replace DispatchQueues with actors
- Maintain thread-safety guarantees

**Phase 4: Testing & Polish (Week 7)**
- Comprehensive testing of both APIs
- Performance benchmarking
- Documentation updates

**Phase 5: Deprecation Path (Future)**
- Mark completion-based APIs as deprecated (iOS 18+)
- Full removal in major version (2.0)

---

## 3. Detailed Implementation Plan

### 3.1 New Protocol Design

```swift
// Keep existing @objc protocol unchanged
@objc public protocol ExperimentClient {
    @objc func start(_ user: ExperimentUser?, completion: ((Error?) -> Void)?)
    @objc func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)?)
    // ... all existing methods
}

// New Swift-only async protocol
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public protocol AsyncExperimentClient: ExperimentClient {
    /// Start the client with async/await
    func start(_ user: ExperimentUser?) async throws

    /// Fetch variants with async/await
    /// - Returns: Self for method chaining
    @discardableResult
    func fetch(user: ExperimentUser?, options: FetchOptions?) async throws -> Self

    /// All sync methods inherited from ExperimentClient:
    /// - variant(_:)
    /// - variant(_:fallback:)
    /// - all()
    /// - exposure(key:)
    /// - setUser(_:)
    /// - getUser()
    /// - clear()
    /// - stop()
}
```

### 3.2 Implementation Architecture

```swift
@available(iOS 13.0, *)
internal actor DefaultAsyncExperimentClient: AsyncExperimentClient, @unchecked Sendable {
    // Actor-isolated state
    private var variants: LoadStoreCache<Variant>
    private var flags: LoadStoreCache<EvaluationFlag>
    private var currentUser: ExperimentUser?

    // Non-isolated config (immutable)
    nonisolated let config: ExperimentConfig

    // Legacy GCD client for backward compatibility
    private let legacyClient: DefaultExperimentClient

    // MARK: - Async API

    func start(_ user: ExperimentUser?) async throws {
        // Pure async implementation
        if let user = user {
            currentUser = user
        }

        if config.pollOnStart {
            try await updateFlagConfigs()
        }

        if let shouldFetch = config.fetchOnStart?.boolValue, shouldFetch {
            try await fetch(user: user, options: nil)
        }
    }

    func fetch(user: ExperimentUser?, options: FetchOptions?) async throws -> Self {
        if let user = user {
            currentUser = user
        }

        let fetchUser = try await mergeUserWithProvider(timeout: .seconds(10))
        let result = try await fetchInternal(
            user: fetchUser,
            timeoutMillis: config.fetchTimeoutMillis,
            retry: config.retryFetchOnFailure,
            options: options
        )

        await storeVariants(result, options)
        return self
    }

    // MARK: - Sync API (non-isolated for immediate access)

    nonisolated func variant(_ key: String) -> Variant {
        return variant(key, fallback: nil)
    }

    nonisolated func variant(_ key: String, fallback: Variant?) -> Variant {
        // Fast path: read from cache without actor isolation
        // Uses atomic operations or immutable snapshots
        return variantsSnapshot[key] ?? fallback ?? config.fallbackVariant
    }

    // MARK: - Legacy Compatibility

    nonisolated func start(_ user: ExperimentUser?, completion: ((Error?) -> Void)?) {
        Task {
            do {
                try await start(user)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }

    nonisolated func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)?) {
        Task {
            do {
                let client = try await fetch(user: user, options: nil)
                completion?(client, nil)
            } catch {
                completion?(self, error)
            }
        }
    }
}
```

### 3.3 Internal Async Infrastructure

```swift
// MARK: - Async Network Layer

@available(iOS 13.0, *)
extension DefaultAsyncExperimentClient {

    private func fetchInternal(
        user: ExperimentUser,
        timeoutMillis: Int,
        retry: Bool,
        options: FetchOptions?
    ) async throws -> [String: Variant] {
        let variants = try await withTimeout(milliseconds: timeoutMillis) {
            try await performFetch(user: user, options: options)
        }
        return variants
    }

    private func performFetch(
        user: ExperimentUser,
        options: FetchOptions?
    ) async throws -> [String: Variant] {
        let url = buildFetchURL(options: options)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(user)

        // Add custom headers
        for (key, value) in config.customRequestHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ExperimentError("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw FetchError(httpResponse.statusCode, "HTTP \(httpResponse.statusCode)")
        }

        let variants = try JSONDecoder().decode([String: Variant].self, from: data)
        return variants
    }

    private func withTimeout<T>(
        milliseconds: Int,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
                throw ExperimentError("Request timeout after \(milliseconds)ms")
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Async Flag Updates

@available(iOS 13.0, *)
extension DefaultAsyncExperimentClient {

    func updateFlagConfigs() async throws {
        let flags = try await fetchFlags(timeoutMillis: config.fetchTimeoutMillis)
        await storeFlags(flags)
    }

    private func fetchFlags(timeoutMillis: Int) async throws -> [String: EvaluationFlag] {
        let url = URL(string: "\(config.flagsServerUrl)/sdk/v2/flags")!
        var request = URLRequest(url: url)
        request.setValue(config.deploymentKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ExperimentError("Failed to fetch flags")
        }

        let flags = try JSONDecoder().decode([String: EvaluationFlag].self, from: data)
        return flags
    }

    private func storeFlags(_ flags: [String: EvaluationFlag]) async {
        self.flags.clear()
        self.flags.putAll(values: flags)
        self.flags.store()
    }
}
```

### 3.4 Actor Migration for Storage

```swift
// Replace LoadStoreCache with actor-based storage
@available(iOS 13.0, *)
actor VariantStore {
    private var variants: [String: Variant] = [:]
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
        self.variants = storage.load() ?? [:]
    }

    func get(_ key: String) -> Variant? {
        return variants[key]
    }

    func getAll() -> [String: Variant] {
        return variants
    }

    func put(_ key: String, value: Variant) {
        variants[key] = value
    }

    func putAll(_ values: [String: Variant]) {
        variants.merge(values) { _, new in new }
    }

    func remove(_ key: String) {
        variants.removeValue(forKey: key)
    }

    func clear() {
        variants.removeAll()
    }

    func store() {
        storage.save(variants)
    }

    // Non-isolated snapshot for fast reads
    nonisolated func snapshot() -> [String: Variant] {
        // Return immutable copy for non-isolated access
        // This requires careful implementation with atomics or OSAllocatedUnfairLock
        return [:] // Simplified
    }
}
```

### 3.5 Backward Compatibility Layer

```swift
// Keep DefaultExperimentClient for iOS 12 and Objective-C users
internal class DefaultExperimentClient: NSObject, ExperimentClient, @unchecked Sendable {
    // Keep all existing implementation unchanged
    // This ensures no breaking changes for existing users

    // Optional: Add internal bridging to async implementation on iOS 13+
    @available(iOS 13.0, *)
    private lazy var asyncClient: DefaultAsyncExperimentClient? = {
        // Share state with async client if needed
        return nil
    }()
}

// Factory method to create appropriate client
public class Experiment {
    @objc public static func initialize(
        apiKey: String,
        config: ExperimentConfig
    ) -> ExperimentClient {
        if #available(iOS 13.0, *), config.useAsyncImplementation {
            return DefaultAsyncExperimentClient(apiKey: apiKey, config: config)
        } else {
            return DefaultExperimentClient(apiKey: apiKey, config: config)
        }
    }

    @available(iOS 13.0, *)
    public static func initializeAsync(
        apiKey: String,
        config: ExperimentConfig
    ) -> AsyncExperimentClient {
        return DefaultAsyncExperimentClient(apiKey: apiKey, config: config)
    }
}
```

---

## 4. API Usage Examples

### 4.1 Modern Swift (iOS 13+)

```swift
// Initialize
let experiment = Experiment.initializeAsync(
    apiKey: "your-key",
    config: ExperimentConfig()
)

// Start with async/await
Task {
    do {
        try await experiment.start(user)

        // Fetch variants
        try await experiment.fetch(user: user, options: nil)

        // Get variants synchronously (no await needed)
        let variant = experiment.variant("my-flag")

        // Exposure tracking (fire and forget)
        experiment.exposure(key: "my-flag")

    } catch {
        print("Error: \(error)")
    }
}

// In SwiftUI
struct ContentView: View {
    @State private var variant: Variant?
    let experiment: AsyncExperimentClient

    var body: some View {
        Text(variant?.value ?? "default")
            .task {
                try? await experiment.fetch(user: nil, options: nil)
                variant = experiment.variant("my-flag")
            }
    }
}
```

### 4.2 Legacy/Objective-C (All iOS versions)

```swift
// Existing code continues to work unchanged
let experiment = Experiment.initialize(
    apiKey: "your-key",
    config: ExperimentConfig()
)

experiment.fetch(user: user) { client, error in
    if let error = error {
        print("Error: \(error)")
        return
    }

    let variant = client.variant("my-flag")
    print("Variant: \(variant.value ?? "nil")")
}
```

---

## 5. Testing Strategy

### 5.1 Unit Tests

```swift
// Test async API
@available(iOS 13.0, *)
class AsyncExperimentClientTests: XCTestCase {
    func testAsyncFetch() async throws {
        let client = Experiment.initializeAsync(
            apiKey: "test-key",
            config: testConfig
        )

        try await client.fetch(user: testUser, options: nil)

        let variant = client.variant("test-flag")
        XCTAssertEqual(variant.value, "test-value")
    }

    func testTimeout() async throws {
        // Test that timeout works correctly
        let client = createSlowClient()

        do {
            try await client.fetch(user: testUser, options: nil)
            XCTFail("Should have timed out")
        } catch let error as ExperimentError {
            XCTAssertTrue(error.message.contains("timeout"))
        }
    }

    func testConcurrentAccess() async throws {
        let client = Experiment.initializeAsync(
            apiKey: "test-key",
            config: testConfig
        )

        // Test actor isolation with concurrent access
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    try? await client.fetch(user: testUser, options: nil)
                }
            }
        }

        // Verify no race conditions
        let variant = client.variant("test-flag")
        XCTAssertNotNil(variant)
    }
}

// Test backward compatibility
class LegacyExperimentClientTests: XCTestCase {
    func testCompletionHandler() {
        let expectation = expectation(description: "fetch")
        let client = Experiment.initialize(
            apiKey: "test-key",
            config: testConfig
        )

        client.fetch(user: testUser) { client, error in
            XCTAssertNil(error)
            XCTAssertNotNil(client)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}

// Test both APIs work identically
@available(iOS 13.0, *)
class APIParityTests: XCTestCase {
    func testAsyncAndCompletionProduceSameResults() async throws {
        let asyncClient = Experiment.initializeAsync(
            apiKey: "test-key",
            config: testConfig
        )

        let legacyClient = Experiment.initialize(
            apiKey: "test-key",
            config: testConfig
        )

        // Fetch with async
        try await asyncClient.fetch(user: testUser, options: nil)
        let asyncVariant = asyncClient.variant("test-flag")

        // Fetch with completion
        let expectation = expectation(description: "fetch")
        var legacyVariant: Variant?

        legacyClient.fetch(user: testUser) { _, _ in
            legacyVariant = legacyClient.variant("test-flag")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 5)

        // Verify same results
        XCTAssertEqual(asyncVariant, legacyVariant)
    }
}
```

### 5.2 Integration Tests

```swift
@available(iOS 13.0, *)
class IntegrationTests: XCTestCase {
    func testRealNetworkRequest() async throws {
        let client = Experiment.initializeAsync(
            apiKey: ProcessInfo.processInfo.environment["EXPERIMENT_API_KEY"]!,
            config: ExperimentConfig()
        )

        let user = ExperimentUser.Builder()
            .userId("test-user")
            .build()

        try await client.fetch(user: user, options: nil)

        let variant = client.variant("ios-test-flag")
        XCTAssertNotNil(variant)
    }

    func testPolling() async throws {
        var config = ExperimentConfig()
        config.pollOnStart = true
        config.flagConfigPollingIntervalMillis = 1000

        let client = Experiment.initializeAsync(
            apiKey: "test-key",
            config: config
        )

        try await client.start(nil)

        // Wait for poll
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Verify flags were updated
        let all = client.all()
        XCTAssertFalse(all.isEmpty)
    }
}
```

### 5.3 Performance Tests

```swift
@available(iOS 13.0, *)
class PerformanceTests: XCTestCase {
    func testVariantAccessPerformance() {
        let client = setupClientWithVariants()

        measure {
            for _ in 0..<10000 {
                _ = client.variant("test-flag")
            }
        }
    }

    func testConcurrentFetchPerformance() async throws {
        let client = Experiment.initializeAsync(
            apiKey: "test-key",
            config: testConfig
        )

        measure {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<100 {
                    group.addTask {
                        try? await client.fetch(user: testUser, options: nil)
                    }
                }
            }
        }
    }
}
```

---

## 6. Migration Checklist

### Pre-Migration
- [ ] Review all GCD usage patterns
- [ ] Identify thread-safety assumptions
- [ ] Document current behavior
- [ ] Set up iOS 13+ test environment
- [ ] Create performance baseline

### Phase 1: Foundation
- [ ] Create AsyncExperimentClient protocol
- [ ] Implement DefaultAsyncExperimentClient skeleton
- [ ] Add Task-based bridging for completion handlers
- [ ] Create VariantStore actor
- [ ] Add timeout utilities
- [ ] Write initial tests

### Phase 2: Core Implementation
- [ ] Implement async start()
- [ ] Implement async fetch()
- [ ] Migrate network layer to URLSession async API
- [ ] Add retry logic with Task.sleep
- [ ] Implement exposure tracking
- [ ] Add comprehensive error handling

### Phase 3: Actor Migration
- [ ] Convert storage to actors
- [ ] Remove DispatchQueue usage where possible
- [ ] Ensure thread-safety with actor isolation
- [ ] Add nonisolated methods for sync access
- [ ] Performance optimization

### Phase 4: Testing
- [ ] Unit test all async methods
- [ ] Test backward compatibility
- [ ] Integration tests with real API
- [ ] Performance benchmarking
- [ ] Memory leak testing
- [ ] Stress testing with concurrent operations

### Phase 5: Documentation
- [ ] Update API documentation
- [ ] Add migration guide
- [ ] Create code examples
- [ ] Update README
- [ ] Add inline documentation

### Phase 6: Release
- [ ] Beta testing period
- [ ] Gather feedback
- [ ] Fix issues
- [ ] Release as minor version (1.19.0)
- [ ] Announce availability

---

## 7. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing apps | High | Keep all existing APIs, add new alongside |
| Performance regression | Medium | Extensive benchmarking, actor optimization |
| iOS version fragmentation | Medium | Support both GCD and async/await paths |
| Increased complexity | Medium | Clear separation of implementations |
| Testing overhead | Low | Automated tests for both APIs |
| Documentation burden | Low | Comprehensive examples and guides |

---

## 8. Timeline & Resources

### Estimated Timeline: 7 weeks

**Week 1-2: Foundation**
- 1 senior engineer
- Set up infrastructure
- Create protocols

**Week 3-4: Core Implementation**
- 2 engineers
- Async API implementation
- Network layer migration

**Week 5-6: Actor Migration**
- 1 senior engineer
- Convert to actors
- Performance optimization

**Week 7: Testing & Polish**
- 1 engineer + QA
- Comprehensive testing
- Documentation

### Success Metrics
- 100% backward compatibility maintained
- 0 breaking changes to existing APIs
- Performance within 5% of current implementation
- 90%+ test coverage for async paths
- <10 open issues after 1 month beta period

---

## 9. Future Enhancements (Post-Migration)

### Phase 6: AsyncSequence APIs (Optional)
```swift
// Streaming variants
func variantUpdates(for key: String) -> AsyncStream<Variant> {
    AsyncStream { continuation in
        // Emit variants as they update
    }
}

// Streaming exposure events
func exposures() -> AsyncStream<Exposure> {
    AsyncStream { continuation in
        // Emit each exposure
    }
}
```

### Phase 7: Deprecation (iOS 18+, 2025)
- Mark completion-based APIs as deprecated
- Encourage migration to async/await
- Keep for 2+ years before removal

### Phase 8: Full Swift Concurrency (2.0, 2026)
- Remove GCD completely
- Full actor-based architecture
- Swift-only (drop @objc)
- Breaking major version

---

## 10. Decision Points

Before proceeding, decide:

1. **Minimum iOS version for async API**: iOS 13.0 recommended (async/await available)
2. **Dual implementation**: Maintain both or share internals?
3. **Migration timeline**: Aggressive (3 months) or conservative (6 months)?
4. **Testing strategy**: Unit tests only or full integration suite?
5. **Documentation approach**: Inline, wiki, or separate guide?

---

This plan provides a complete roadmap for migrating to async/await while maintaining full backward compatibility. The phased approach minimizes risk and allows for course correction based on feedback.
