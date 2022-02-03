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
    
    func testFetchCalledAndUserUpdatedOnUserIdentityChange() {
        let instanceName = "integration_test"
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
        let connector = AnalyticsConnector.getInstance("integration_test")
        let config = ExperimentConfigBuilder().instanceName("integration_test").build()
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
}
