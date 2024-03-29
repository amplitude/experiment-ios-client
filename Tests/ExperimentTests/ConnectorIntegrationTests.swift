//
//  ConnectorIntegrationTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 1/6/22.
//

import XCTest
import Foundation
import AnalyticsConnector
@testable import Experiment

class ConnectorIntegrationTests : XCTestCase {
    
    let API_KEY = "client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3"
    
    func testConnectorUserProviderConcurrency() {
        let connector = AnalyticsConnector.getInstance("test")
        let userProvider = ConnectorUserProvider(identityStore: connector.identityStore)
        DispatchQueue.global().async {
            var i = 0
            repeat {
                i += 1
                connector.identityStore.setIdentity(Identity(userId: "\(i)"))
                connector.identityStore.setIdentity(Identity(userId: nil))
                connector.identityStore.setIdentity(Identity(userId: "\(i)"))
            } while i < 10000
        }
        var i = 0
        repeat {
            _ = try? userProvider.getUserOrWait(timeout: .seconds(1))
            i += 1
        } while i < 10000
    }
    
    func testUserIdUpdatePropogates() {
        let instanceName = "integration_test_update"
        let connector = AnalyticsConnector.getInstance(instanceName)
        connector.identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .commit()
        
        let config = ExperimentConfigBuilder()
            .instanceName(instanceName)
            .build()
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: API_KEY, config: config) as! DefaultExperimentClient
        let user = try! client.mergeUserWithProviderOrWait(timeout: .milliseconds(5000))
        let expectedUser = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .build()
        XCTAssertEqual(user.userId, expectedUser.userId)
        XCTAssertEqual(user.deviceId, expectedUser.deviceId)
    }
    
    func testUserUpdatedOnUserIdentityChange() {
        let instanceName = "integration_test1"
        let connector = AnalyticsConnector.getInstance(instanceName)
        let config = ExperimentConfigBuilder()
            .instanceName(instanceName)
            .build()
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: API_KEY, config: config) as! DefaultExperimentClient
        connector.identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["key": "value"]
            ]))
            .commit()
        let user = client.mergeUserWithProvider()
        let expectedUser = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .userProperties(["key": "value"])
            .build()
        XCTAssertEqual(user.userId, expectedUser.userId)
        XCTAssertEqual(user.deviceId, expectedUser.deviceId)
        XCTAssertEqual(NSDictionary(dictionary: user.getUserProperties()!), NSDictionary(dictionary: expectedUser.getUserProperties()!))
}
    
    func testUserPropertiesMergedOnUserIdentityChange() {
        let connector = AnalyticsConnector.getInstance("integration_test2")
        let config = ExperimentConfigBuilder().instanceName("integration_test2").build()
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: API_KEY, config: config) as! DefaultExperimentClient
        connector.identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["key": "value"]
            ]))
            .commit()
        connector.identityStore.editIdentity()
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["other": true]
            ]))
            .commit()
        let user = client.mergeUserWithProvider()
        let expectedUser = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .userProperties(["key": "value", "other": true])
            .build()
        XCTAssertEqual(user.userId, expectedUser.userId)
        XCTAssertEqual(user.deviceId, expectedUser.deviceId)
        XCTAssertEqual(NSDictionary(dictionary: user.getUserProperties()!), NSDictionary(dictionary: expectedUser.getUserProperties()!))
    }
    
    func testTrackCalledOnceEachPerVariantForDifferentFlagKeys() {
        let eventBridge = TestEventBridge()
        let connectorExposureTrackingProvider = UserSessionExposureTracker(exposureTrackingProvider: ConnectorExposureTrackingProvider(eventBridge: eventBridge))
        
        // Track event with variant
        
        let exposureEvent1 = Exposure(flagKey: "test-key-1", variant: "test", experimentKey: nil, metadata: nil)
        let expectedTrack1 = AnalyticsEvent(eventType: "$exposure", eventProperties: NSDictionary(dictionary: ["flag_key": "test-key-1", "variant": "test"]), userProperties: nil)
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent1)
        XCTAssertEqual(expectedTrack1, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 1)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent1)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 1)

        // Track new flag key event with same variant
        
        let exposureEvent2 = Exposure(flagKey: "test-key-2", variant: "test", experimentKey: nil, metadata: nil)
        let expectedTrack2 = AnalyticsEvent(eventType: "$exposure", eventProperties: NSDictionary(dictionary: ["flag_key": "test-key-2", "variant": "test"]), userProperties: nil)
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent2)
        XCTAssertEqual(expectedTrack2, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 2)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent2)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 2)
    }
    
    func testTrackCalledOncePerVariantForTheSameFlagKey() {
        let eventBridge = TestEventBridge()
        let connectorExposureTrackingProvider = UserSessionExposureTracker(exposureTrackingProvider: ConnectorExposureTrackingProvider(eventBridge: eventBridge))
        
        // Track event with variant
        
        let exposureEvent1 = Exposure(flagKey: "test-key", variant: "test", experimentKey: nil, metadata: nil)
        let expectedTrack1 = AnalyticsEvent(eventType: "$exposure", eventProperties: NSDictionary(dictionary: ["flag_key": "test-key", "variant": "test"]), userProperties: nil)
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent1)
        XCTAssertEqual(expectedTrack1, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 1)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent1)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 1)

        // Track new flag key event with same variant
        
        let exposureEvent2 = Exposure(flagKey: "test-key", variant: "test2", experimentKey: nil, metadata: nil)
        let expectedTrack2 = AnalyticsEvent(eventType: "$exposure", eventProperties: NSDictionary(dictionary: ["flag_key": "test-key", "variant": "test2"]), userProperties: nil)
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent2)
        XCTAssertEqual(expectedTrack2, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 2)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent2)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 2)
        
        // Track event with no variant

        let exposureEvent3 = Exposure(flagKey: "test-key", variant: nil, experimentKey: nil, metadata: nil)
        let expectedTrack3 = AnalyticsEvent(eventType: "$exposure", eventProperties: NSDictionary(dictionary: ["flag_key": "test-key"]), userProperties: nil)
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent3)
        XCTAssertEqual(expectedTrack3, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 3)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent3)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 3)
        
        // Back to variant 1
        
        connectorExposureTrackingProvider.track(exposure: exposureEvent1)
        XCTAssertEqual(expectedTrack1, eventBridge.recentEvent)
        XCTAssertEqual(eventBridge.eventCount, 4)
        for _ in 0..<10 {
            eventBridge.recentEvent = nil
            connectorExposureTrackingProvider.track(exposure: exposureEvent1)
            XCTAssertEqual(nil, eventBridge.recentEvent)
        }
        XCTAssertEqual(eventBridge.eventCount, 4)
    }
}


class TestEventBridge : EventBridge {
    var recentEvent: AnalyticsEvent? = nil
    var eventCount = 0
    func logEvent(event: AnalyticsEvent) {
        recentEvent = event
        eventCount += 1
    }
    
    func setEventReceiver(_ eventReceiver: @escaping (AnalyticsEvent) -> ()) {}
}
