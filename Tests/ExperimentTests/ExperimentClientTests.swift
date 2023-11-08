//
//  ExperimentClientTests.swift
//  ExperimentTests
//
//  Created by Curtis Liu on 12/3/20.
//

import XCTest
@testable import Experiment

let API_KEY = "client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3"
let SERVER_API_KEY = "server-qz35UwzJ5akieoAdIgzM4m9MIiOLXLoz";

let KEY = "sdk-ci-test"
let INITIAL_KEY = "initial-key"

let testUser = ExperimentUserBuilder().userId("test_user").build()
let serverVariant = Variant("on", payload: "payload", key: "on")
let fallbackVariant = Variant("fallback", payload: "payload")
let initialVariant = Variant("initial")
let initialVariants: [String: Variant] = [
    INITIAL_KEY: initialVariant,
    KEY: Variant("off")
]
let KEY2 = "sdk-ci-test-2"
let serverVariant2 = Variant("on")

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
        
        variant = client.variant(INITIAL_KEY)
        XCTAssertEqual(initialVariant, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
    }
    
    func testFetchWithFlags() {
        let s = DispatchSemaphore(value: 0)
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .build(),
            storage: InMemoryStorage()
        )
        let options = FetchOptions([KEY, KEY2])
        client.fetch(user: testUser, options: options) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertEqual(serverVariant, variant)
            let variant2 = client.variant(KEY2, fallback: nil)
            XCTAssertEqual(serverVariant2, variant2)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchWithPartialFlags() {
        let s = DispatchSemaphore(value: 0)
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .build(),
            storage: InMemoryStorage()
        )
        let options = FetchOptions([KEY2])
        client.fetch(user: testUser, options: options) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertNil(variant.value)
            let variant2 = client.variant(KEY2, fallback: nil)
            XCTAssertEqual(serverVariant2, variant2)
            s.signal()
        }
        s.wait()
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
    
    func testClearFlagConfig() {
        let storage = InMemoryStorage()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .debug(true)
                .build(),
            storage: storage
        )
        client.variants.put(key: "sdk-ci-test", value: serverVariant)

        let variant = client.variant("sdk-ci-test")
        XCTAssertNotNil(variant)
        XCTAssertEqual(serverVariant, variant)

        client.clear()
        let clearedVariants = client.all()
        let clearedVariant = client.variant("sdk-ci-test")
        XCTAssertNil(clearedVariant.value)
        XCTAssertTrue(clearedVariants.isEmpty)
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
        let storage = InMemoryStorage()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .analyticsProvider(analyticsProvider)
                .build(),
            storage: storage
        )
        client.variants.put(key: KEY, value: serverVariant)
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
    
    func testVariantWithExperimentKeyInExposure() {
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: ExperimentConfigBuilder()
                .exposureTrackingProvider(exposureTrackingProvider)
                .source(Source.InitialVariants)
                .initialVariants(["flagKey": Variant("value", payload: nil, expKey: "expKey")])
                .build(),
            storage: InMemoryStorage()
        )
        _ = client.variant("flagKey")
        XCTAssertEqual(exposureTrackingProvider.lastExposure, Exposure(flagKey: "flagKey", variant: "value", experimentKey: "expKey", metadata: nil))
        XCTAssertEqual(exposureTrackingProvider.trackCount, 1)
    }
    
    // Local Evaluation Tests
    
    func testStartLoadsFlagsIntoStorage() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .deviceId("test_device")
            .build()
        client.startBlocking(user: user)
        let flagKey = client.flags.get(key: "sdk-ci-test-local")?.key
        XCTAssertEqual("sdk-ci-test-local", flagKey)
    }
    
    func testVariantAfterStartReturnsExpectedLocallyEvaluatedVariant() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .deviceId("test_device")
            .build()
        client.startBlocking(user: user)
        var variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual("on", variant.key)
        XCTAssertEqual("on", variant.value)
        client.setUser(nil)
        variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual("off", variant.key)
        XCTAssertEqual(nil, variant.value)
    }
    
    func testRemoteEvaluationVariantPreferredOverLocalEvaluationVariant() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .fetchOnStart(false)
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .deviceId("test_device")
            .build()
        client.startBlocking(user: user)
        var variant = client.variant("sdk-ci-test")
        XCTAssertEqual("off", variant.key)
        XCTAssertEqual(nil, variant.value)
        client.fetchBlocking(user: user)
        variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "on", value: "on", payload: "payload"), variant)
    }
    
    // Server Zone Tests
    
    func testNoConfigUsesDefaults() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        XCTAssertEqual("https://api.lab.amplitude.com", client.config.serverUrl)
        XCTAssertEqual("https://flag.lab.amplitude.com", client.config.flagsServerUrl)
    }
    
    func testUsServerZoneConfigUsesDefaults() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .serverZone(.US)
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        XCTAssertEqual("https://api.lab.amplitude.com", client.config.serverUrl)
        XCTAssertEqual("https://flag.lab.amplitude.com", client.config.flagsServerUrl)
    }
    
    func testUsServerZoneWithExplicitConfigUsesExplicitConfig() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .serverZone(.US)
            .serverUrl("https://experiment.company.com")
            .flagsServerUrl("https://flags.company.com")
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        XCTAssertEqual("https://experiment.company.com", client.config.serverUrl)
        XCTAssertEqual("https://flags.company.com", client.config.flagsServerUrl)
    }
    
    func testEuServerZoneUsesEuDefaults() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .serverZone(.EU)
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        XCTAssertEqual("https://api.lab.eu.amplitude.com", client.config.serverUrl)
        XCTAssertEqual("https://flag.lab.eu.amplitude.com", client.config.flagsServerUrl)
    }
    
    func testEuServerZoneWithExplicitConfigUsesExplicitConfig() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .serverZone(.EU)
            .serverUrl("https://experiment.company.com")
            .flagsServerUrl("https://flags.company.com")
            .build()
        let client = DefaultExperimentClient(
            apiKey: SERVER_API_KEY,
            config: config,
            storage: storage
        )
        XCTAssertEqual("https://experiment.company.com", client.config.serverUrl)
        XCTAssertEqual("https://flags.company.com", client.config.flagsServerUrl)
    }
    
    // Fallback Tests
    
    // Local Storage Source
    
    func testLocalStorage_AccessedFromLocalStoragePrimary() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual("on", variant.key)
        XCTAssertEqual("on", variant.value)
        XCTAssertEqual("payload", variant.payload as! String)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual("on", exposureTrackingProvider.lastExposure?.variant)

    }
    
    func testLocalStorage_AccessedFromInlineFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test", fallback: Variant(value: "inline"))
        XCTAssertEqual(Variant("inline"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalStorage_AccessedFromInitialVariants_NoExplicitFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "initial", value: "initial"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalStorage_AccessedFromConfiguredFallback_NoInitialVariantsOrExplicitFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-not-selected": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "fallback", value: "fallback"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalStorage_DefaultVariantReturned_NoOtherFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual("off", variant.key)
        XCTAssertEqual(nil, variant.value)
        XCTAssertEqual(true, variant.metadata?["default"] as! Bool)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    // Initial Variants Source
    
    func testInitialVariants_AccessedFromInitialVariantsPrimary() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "initial", value: "initial"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual("initial", exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testInitialVariants_AccessedFromLocalStorageSecondary() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-not-selected": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "on", value: "on", payload: "payload"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual("on", exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testInitialVariants_AccessedFromInlineFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-not-selected": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test", fallback: Variant(value: "inline"))
        XCTAssertEqual(Variant("inline"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testInitialVariants_AccessedFromConfiguredFallback_NoInitialVariantsOrExplicitFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-not-selected": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual(Variant(key: "fallback", value: "fallback"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testInitialVariants_DefaultVariantReturned_NoOtherFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        XCTAssertEqual("off", variant.key)
        XCTAssertEqual(nil, variant.value)
        XCTAssertEqual(true, variant.metadata?["default"] as! Bool)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    // Local Evaluation Source
    
    func testLocalEvaluation_ReturnsLocallyEvaluatedVariant() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-local": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .deviceId("0123456789")
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual("on", variant.key)
        XCTAssertEqual("on", variant.value)
        XCTAssertEqual("local", variant.metadata?["evaluationMode"] as! String)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test-local", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual("on", exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalEvaluation_LocallyEvaluatedDefaultVariant_WithInlineFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-local": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test-local", fallback: Variant("inline"))
        XCTAssertEqual(Variant("inline"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test-local", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalEvaluation_LocallyEvaluatedDefaultVariant_WithInitialVariants() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-local": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual(Variant(key: "initial", value: "initial"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test-local", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalEvaluation_LocallyEvaluatedDefaultVariant_WithConfiguredFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants(["sdk-ci-test-local-not-selected": Variant(key: "initial", value: "initial")])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual(Variant(key: "fallback", value: "fallback"), variant)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test-local", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    func testLocalEvaluation_DefaultVariantReturned_NoOtherFallback() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test-local")
        XCTAssertEqual("off", variant.key)
        XCTAssertEqual(nil, variant.value)
        XCTAssertEqual(1, exposureTrackingProvider.trackCount)
        XCTAssertEqual("sdk-ci-test-local", exposureTrackingProvider.lastExposure?.flagKey)
        XCTAssertEqual(nil, exposureTrackingProvider.lastExposure?.variant)
    }
    
    // All
    
    func testAll_ReturnsLocalEvaluationVariant_OverRemoteOrInitialVariants_LocalStorageSource() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.LocalStorage)
            .fetchOnStart(true)
            .initialVariants([
                "sdk-ci-test": Variant(key: "initial", value: "initial"),
                "sdk-ci-test-local": Variant(key: "initial", value: "initial")
            ])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .deviceId("0123456789")
            .build()
        client.startBlocking(user: user)
        let allVariants = client.all()
        let localVariant = allVariants["sdk-ci-test-local"]
        XCTAssertEqual("on", localVariant?.key)
        XCTAssertEqual("on", localVariant?.value)
        XCTAssertEqual("local", localVariant?.metadata?["evaluationMode"] as! String)
        let remoteVariant = allVariants["sdk-ci-test"]
        XCTAssertEqual("on", remoteVariant?.key)
        XCTAssertEqual("on", remoteVariant?.value)
    }
    
    func testAll_ReturnsLocalEvaluationVariant_OverRemoteOrInitialVariants_InitialVariantsSource() {
        let storage = InMemoryStorage()
        let exposureTrackingProvider = TestExposureTrackingProvider()
        let config = ExperimentConfigBuilder()
            .exposureTrackingProvider(exposureTrackingProvider)
            .source(.InitialVariants)
            .fetchOnStart(true)
            .initialVariants([
                "sdk-ci-test": Variant(key: "initial", value: "initial"),
                "sdk-ci-test-local": Variant(key: "initial", value: "initial")
            ])
            .fallbackVariant(Variant(key: "fallback", value: "fallback"))
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .deviceId("0123456789")
            .build()
        client.startBlocking(user: user)
        let allVariants = client.all()
        let localVariant = allVariants["sdk-ci-test-local"]
        XCTAssertEqual("on", localVariant?.key)
        XCTAssertEqual("on", localVariant?.value)
        XCTAssertEqual("local", localVariant?.metadata?["evaluationMode"] as! String)
        let remoteVariant = allVariants["sdk-ci-test"]
        XCTAssertEqual("initial", remoteVariant?.key)
        XCTAssertEqual("initial", remoteVariant?.value)
    }
    
    // Start Tests
    
    private class MockClient: DefaultExperimentClient {
        
        var fetchCalls = 0
        var mockFetch: (() -> Result<[String: Variant], Error>)? = nil
        var flagCalls = 0
        var mockFlags: (() -> Result<[String: EvaluationFlag], Error>)? = nil
        
        override func doFetch(
            user: ExperimentUser,
            timeoutMillis: Int,
            options: FetchOptions?,
            completion: @escaping ((Result<[String: Variant], Error>) -> Void)
        ) -> URLSessionTask? {
            fetchCalls += 1
            if let mockFetch = mockFetch {
                completion(mockFetch())
                return nil
            } else {
                return super.doFetch(user: user, timeoutMillis: timeoutMillis, options: options, completion: completion)
            }
        }
        
        override func doFlags(
            timeoutMillis: Int,
            completion: @escaping ((Result<[String: EvaluationFlag], Error>) -> Void)
        ) {
            flagCalls += 1
            if let mockFlags = mockFlags {
                completion(mockFlags())
            } else {
                super.doFlags(timeoutMillis: timeoutMillis, completion: completion)
            }
        }
    }
    
    func testStart_WithLocalAndRemoteEvaluation_CallsFetch() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .build()
        let client = DefaultExperimentClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        let user = ExperimentUserBuilder()
            .userId("test_user")
            .build()
        client.startBlocking(user: user)
        let variant = client.variant("sdk-ci-test")
        // If we get on for the variant, fetch must be called.
        XCTAssertEqual("on", variant.key)
        XCTAssertEqual("on", variant.value)
    }
    
    func testStart_WithLocalEvaluationOnly_CallsFetch() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .build()
        let client = MockClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        client.mockFlags = {
            return .success([:])
        }
        client.mockFetch = {
            return .success([:])
        }
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        XCTAssertEqual(1, client.fetchCalls)
        client.fetchBlocking(user: user)
        XCTAssertEqual(2, client.fetchCalls)
    }
    
    func testStart_WithLocalEvalautionOnly_FetchOnStartEnabled_CallsFetch() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .fetchOnStart(true)
            .build()
        let client = MockClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        client.mockFlags = {
            return .success([:])
        }
        client.mockFetch = {
            return .success([:])
        }
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        XCTAssertEqual(1, client.fetchCalls)
        client.fetchBlocking(user: user)
        XCTAssertEqual(2, client.fetchCalls)
    }
    
    func testStart_WithLocalEvalautionOnly_FetchOnStartDisabled_DoesNotCallFetch() {
        let storage = InMemoryStorage()
        let config = ExperimentConfigBuilder()
            .fetchOnStart(false)
            .build()
        let client = MockClient(
            apiKey: API_KEY,
            config: config,
            storage: storage
        )
        client.mockFlags = {
            return .success([:])
        }
        client.mockFetch = {
            return .success([:])
        }
        let user = ExperimentUserBuilder()
            .build()
        client.startBlocking(user: user)
        XCTAssertEqual(0, client.fetchCalls)
        client.fetchBlocking(user: user)
        XCTAssertEqual(1, client.fetchCalls)
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

class InMemoryStorage: Storage {
    private var store: [String: Data] = [:]
    func get(key: String) -> Data? {
        return store[key]
    }
    
    func put(key: String, value: Data) {
        store[key] = value
    }
    
    func delete(key: String) {
        store.removeValue(forKey: key)
    }
}

extension DefaultExperimentClient {
    func startBlocking(user: ExperimentUser) {
        let s = DispatchSemaphore(value: 0)
        start(user) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            s.signal()
        }
        switch s.wait(timeout: .now() + .seconds(20)) {
        case .timedOut: XCTFail("start request timed out")
        case .success: return
        }
    }
    func startBlockingThrows(user: ExperimentUser) throws {
        let s = DispatchSemaphore(value: 0)
        var err: Error?
        start(user) { error in
            if let error = error {
                err = error
            }
            s.signal()
        }
        switch s.wait(timeout: .now() + .seconds(20)) {
        case .timedOut: XCTFail("start request timed out")
        case .success:
            if let error = err {
                throw error
            }
        }
    }
    func fetchBlocking(user: ExperimentUser) {
        let s = DispatchSemaphore(value: 0)
        fetch(user: user) { _, error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            s.signal()
        }
        switch s.wait(timeout: .now() + .seconds(20)) {
        case .timedOut: XCTFail("start request timed out")
        case .success: return
        }
    }
}
