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
    
    func testFetch() {
        let s = DispatchSemaphore(value: 0)
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .build(),
            storage: InMemoryStorage()
        )
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertEqual(serverVariant, variant)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchTimeout() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fetchTimeoutMillis(1)
                .fetchRetryOnFailure(false)
                .build(),
            storage: InMemoryStorage()
        )
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY)
            XCTAssertEqual(nil, variant.value)
            s.signal()
        }
        s.wait()
        _ = s.wait(timeout: .now() + .seconds(1))
        let variant = client.variant(KEY, fallback: nil)
        XCTAssertEqual(nil, variant.value)
    }

    func testFetchTimeoutAndRetrySuccess() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fetchTimeoutMillis(1)
                .fetchRetryOnFailure(true)
                .build(),
            storage: InMemoryStorage()
        )
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY)
            XCTAssertEqual(nil, variant.value)
            s.signal()
        }
        s.wait()
        // Wait for retry to succeed
        _ = s.wait(timeout: .now() + .seconds(2))
        let variant = client.variant(KEY, fallback: nil)
        XCTAssertEqual(serverVariant, variant)
    }
    
    func testFallbackVariantReturnedInCorrectOrder() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fallbackVariant(fallbackVariant)
                .initialVariants(initialVariants)
                .build(),
            storage: InMemoryStorage()
        )
        let firstFallback = Variant("first")
        var variant = client.variant("asdf", fallback: firstFallback)
        XCTAssertEqual(firstFallback, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
    }
    
    func testInitialVariantsReturned() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fallbackVariant(fallbackVariant)
                .initialVariants(initialVariants)
                .build(),
            storage: InMemoryStorage()
        )
        let variants = client.all()
        XCTAssertEqual(initialVariants, variants)
    }
    
    func testMergeUserWithProvider() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fallbackVariant(fallbackVariant)
                .initialVariants(initialVariants)
                .build(),
            storage: InMemoryStorage()
        )
        _ = client.setUserProvider(TestUserProvider())
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
        let initialVariantSourceClient = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .initialVariants(initialVariants)
                .source(.InitialVariants)
                .build(),
            storage: InMemoryStorage()
        )
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
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .fallbackVariant(fallbackVariant)
                .initialVariants(initialVariants)
                .build(),
            storage: InMemoryStorage()
        )

        client.fetch(user: testUser)
        XCTAssertEqual(testUser, client.getUser())
        let newUser = testUser.copyToBuilder().userId("different_user").build()
        client.setUser(newUser)
        XCTAssertEqual(newUser, client.getUser())
    }
    
    func testExposureEventThroughAnalyticsProviderWhenVariantCalled() {
        let analyticsProvider = TestAnalyticsProvider(track: { event in
            XCTAssertEqual("[Experiment] Exposure", event.name)
            let exposureEvent = event as! ExposureEvent
            XCTAssertEqual(event.properties, [
                "key": KEY,
                "variant": serverVariant.value,
                "source": "storage"
            ])
            XCTAssertEqual(KEY, exposureEvent.key)
            XCTAssertEqual(serverVariant, exposureEvent.variant)
        }, setUserProperty: { event in
            XCTAssertEqual("[Experiment] \(KEY)", event.userProperty)
        }, unsetUserProperty: { _ in
            XCTFail()
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
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
    
    func testExposureEventNotTrackedOnFallbackAndUnsetCalled() {
        let analyticsProvider = TestAnalyticsProvider(track: { _ in
            XCTFail()
        }, setUserProperty: { _ in
            XCTFail()
        }, unsetUserProperty: { event in
            XCTAssertEqual("[Experiment] asdf", event.userProperty)
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .analyticsProvider(analyticsProvider)
                .initialVariants(initialVariants)
                .fallbackVariant(fallbackVariant)
                .build(),
            storage: InMemoryStorage()
        )
        _ = client.variant("asdf")
        XCTAssertTrue(analyticsProvider.didUserPropertyGetUnset)
    }

    func testExposureEventNotTrackedOnSecondaryAndUnsetNotCalled() {
        let analyticsProvider = TestAnalyticsProvider(track: { event in
            XCTAssertEqual("[Experiment] Exposure", event.name)
            let exposureEvent = event as! ExposureEvent
            XCTAssertEqual(event.properties, [
                "key": INITIAL_KEY,
                "variant": initialVariants[INITIAL_KEY]!.value,
                "source": "secondary-initial"
            ])
            XCTAssertEqual(INITIAL_KEY, exposureEvent.key)
            XCTAssertEqual(initialVariants[INITIAL_KEY], exposureEvent.variant)
        }, setUserProperty: { event in
            XCTFail()
        }, unsetUserProperty: { event in
            XCTAssertEqual("[Experiment] \(INITIAL_KEY)", event.userProperty)
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .analyticsProvider(analyticsProvider)
                .initialVariants(initialVariants)
                .fallbackVariant(fallbackVariant)
                .build(),
            storage: InMemoryStorage()
        )
        _ = client.variant(INITIAL_KEY)
        XCTAssertFalse(analyticsProvider.didExposureGetTracked)
        XCTAssertFalse(analyticsProvider.didUserPropertyGetSet)
    }
    
    func testExposureEventThroughAnalyticsProviderWithUserProperties() {
        let analyticsProvider = TestAnalyticsProvider(track: { event in
            let actualValue = event.userProperties?["[Experiment] \(KEY)"] as! String
            XCTAssertEqual(actualValue, serverVariant.value)
        }, setUserProperty: {event in
            XCTAssertEqual("[Experiment] \(KEY)", event.userProperty)
        }, unsetUserProperty: { _ in
            XCTFail()
        })
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
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
    
    func testEmptyUserDoesNotOverwriteCurrentUser() {
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .build(),
            storage: InMemoryStorage()
        )
        let user = ExperimentUserBuilder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .build()
        client.setUser(user)
        client.fetch(user: ExperimentUser())
        let storedUser = client.getUser()
        XCTAssertEqual(storedUser, user)
    }
}

class TestAnalyticsProvider : ExperimentAnalyticsProvider {
    var didExposureGetTracked = false
    var didUserPropertyGetSet = false
    var didUserPropertyGetUnset = false
    let _track: (ExperimentAnalyticsEvent) -> ()
    let _setUserProperty: (ExperimentAnalyticsEvent) -> ()
    let _unsetUserProperty: (ExperimentAnalyticsEvent) -> ()
    init(track: @escaping (ExperimentAnalyticsEvent) -> (), setUserProperty: @escaping (ExperimentAnalyticsEvent) -> (), unsetUserProperty: @escaping (ExperimentAnalyticsEvent) -> ()) {
        self._track = track
        self._setUserProperty = setUserProperty
        self._unsetUserProperty = unsetUserProperty
    }
    func track(_ event: ExperimentAnalyticsEvent) {
        _track(event)
        didExposureGetTracked = true
    }
    func setUserProperty(_ event: ExperimentAnalyticsEvent) {
        _setUserProperty(event)
        didUserPropertyGetSet = true
    }
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        _unsetUserProperty(event)
        didUserPropertyGetUnset = true
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
