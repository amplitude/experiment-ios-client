//
//  ExperimentClientTests.swift
//  ExperimentTests
//
//  Created by Curtis Liu on 12/3/20.
//

import XCTest
@testable import Experiment

let API_KEY = "client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3"
let KEY = "sdk-ci-test"
let INITIAL_KEY = "initial-key"

let testUser = ExperimentUserBuilder().userId("test_user").build()
let serverVariant = Variant("on", payload: "payload")
let fallbackVariant = Variant("fallback", payload: "payload")
let initialVariant = Variant("initial")
let initialVariants: [String: Variant] = [
    INITIAL_KEY: initialVariant,
    KEY: Variant("off")
]

class ExperimentClientTests: XCTestCase {
    
    let client = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfigBuilder()
            .debug(true)
            .fallbackVariant(fallbackVariant)
            .initialVariants(initialVariants)
            .build(),
        storage: InMemoryStorage()
    )
    
    let timeoutClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfigBuilder()
            .debug(true)
            .fallbackVariant(fallbackVariant)
            .initialVariants(initialVariants)
            .fetchTimeoutMillis(1)
            .fetchRetryOnFailure(false)
            .build(),
        storage: InMemoryStorage()
    )

    let timeoutRetryClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfigBuilder()
            .debug(true)
            .fallbackVariant(fallbackVariant)
            .initialVariants(initialVariants)
            .fetchTimeoutMillis(1)
            .fetchRetryOnFailure(true)
            .build(),
        storage: InMemoryStorage()
    )
    
    let initialVariantSourceClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfigBuilder()
            .debug(true)
            .initialVariants(initialVariants)
            .source(.InitialVariants)
            .build(),
        storage: InMemoryStorage()
    )
    
    override class func setUp() {
    }
    
    func testFetch() {
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertEqual(serverVariant, variant)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchTimeout() {
        let s = DispatchSemaphore(value: 0)
        timeoutClient.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY)
            XCTAssertEqual("off", variant.value)
            s.signal()
        }
        s.wait()
        // Wait for retry to succeed
        _ = s.wait(timeout: .now() + .seconds(1))
        let variant = timeoutClient.variant(KEY, fallback: nil)
        XCTAssertEqual("off", variant.value)
    }

    func testFetchTimeoutAndRetrySuccess() {
        let s = DispatchSemaphore(value: 0)
        timeoutRetryClient.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY)
            XCTAssertEqual("off", variant.value)
            s.signal()
        }
        s.wait()
        // Wait for retry to succeed
        _ = s.wait(timeout: .now() + .seconds(2))
        let variant = timeoutRetryClient.variant(KEY, fallback: nil)
        XCTAssertEqual(serverVariant, variant)
    }
    
    func testFallbackVariantReturnedInCorrectOrder() {
        let firstFallback = Variant("first")
        var variant = client.variant("asdf", fallback: firstFallback)
        XCTAssertEqual(firstFallback, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
    }
    
    func testInitialVariantsReturned() {
        let variants = client.all()
        XCTAssertEqual(initialVariants, variants)
    }
    
    func testMergeUserWithProvider() {
        _ = client.setUserProvider(TestContextProvider())
        let user = ExperimentUserBuilder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .build()
        client.setUser(user)
        let mergedUser = client.mergeUserWithProvider()
        let expectedUserAfterMerge = ExperimentUserBuilder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .language("")
            .library("\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)")
            .build()
        XCTAssertEqual(expectedUserAfterMerge, mergedUser)
    }
    
    func testMergeUserWithConfiguredProvider() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .userProvider(TestUserProvider())
                .build(),
            storage: InMemoryStorage()
        )
        let user = ExperimentUserBuilder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .build()
        client.setUser(user)
        let mergedUser = client.mergeUserWithProvider()
        let expectedUserAfterMerge = ExperimentUserBuilder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .language("")
            .library("\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)")
            .build()
        XCTAssertEqual(expectedUserAfterMerge, mergedUser)
    }
    
    
    func testInitialVariantsSourceOverridesFetch() {
        var variant = initialVariantSourceClient.variant(KEY, fallback: nil)
        XCTAssertNotNil(variant)
        let s = DispatchSemaphore(value: 0)
        initialVariantSourceClient.fetch(user: testUser) { (client, error) in
            variant = client.variant(KEY, fallback: nil)
            XCTAssertNotNil(variant)
            XCTAssertEqual("off", variant.value)
            XCTAssertNil(variant.payload)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchSetsUserAndsetUserOverwrites() {
        client.fetch(user: testUser)
        XCTAssertEqual(testUser, client.getUser())
        let newUser = testUser.copyToBuilder().userId("different_user").build()
        client.setUser(newUser)
        XCTAssertEqual(newUser, client.getUser())
    }
    
    func testExposureEventThroughAnalyticsProviderWhenVariantCalled() {
        let analyticsProvider = TestAnalyticsProvider(block: { event in
            XCTAssertEqual("[Experiment] Exposure", event.name)
            let exposureEvent = event as! ExposureEvent
            XCTAssertEqual(event.properties, [
                "key": KEY,
                "variant": serverVariant.value
            ])
            XCTAssertEqual(KEY, exposureEvent.key)
            XCTAssertEqual(serverVariant, exposureEvent.variant)
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfig.Builder()
                .analyticsProvider(analyticsProvider)
                .build(),
            storage: InMemoryStorage()
        )
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (_, _) in
            s.signal()
        }
        s.wait()
        _ = client.variant(KEY)
        XCTAssertTrue(analyticsProvider.didExposureGetTracked)
    }
    
    func testExposureEventNotTrackedOnFallback() {
        let analyticsProvider = TestAnalyticsProvider(block: { _ in
            XCTFail()
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfig.Builder()
                .analyticsProvider(analyticsProvider)
                .initialVariants(initialVariants)
                .fallbackVariant(fallbackVariant)
                .build(),
            storage: InMemoryStorage()
        )
        _ = client.variant(INITIAL_KEY)
        _ = client.variant("asdf")
    }
    
    func testExposureEventThroughAnalyticsProviderWithUserProperties() {
        let analyticsProvider = TestAnalyticsProvider(block: { event in
            let actualValue = event.userProperties?["[Experiment] \(KEY)"] as! String
            XCTAssertEqual(actualValue, serverVariant.value)
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfig.Builder()
                .analyticsProvider(analyticsProvider)
                .build(),
            storage: InMemoryStorage()
        )
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (_, _) in
            s.signal()
        }
        s.wait()
        _ = client.variant(KEY)
        XCTAssertTrue(analyticsProvider.didExposureGetTracked)
    }
}

class TestAnalyticsProvider : ExperimentAnalyticsProvider {
    var didExposureGetTracked = false
    let block: (ExperimentAnalyticsEvent) -> ()
    init(block: @escaping (ExperimentAnalyticsEvent) -> ()) {
        self.block = block
    }
    func track(_ event: ExperimentAnalyticsEvent) {
        block(event)
        didExposureGetTracked = true
    }
}

class TestUserProvider : ExperimentUserProvider {
    func getUser() -> ExperimentUser {
        return ExperimentUserBuilder()
            .deviceId("")
            .version("version2")
            .language("")
            .build()
    }
}
