//
//  CoreIntegrationTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 1/6/22.
//

import XCTest
import Foundation
@testable import Experiment
@testable import AmplitudeCore

class CoreIntegrationTests : XCTestCase {
    
    let API_KEY = "client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3"
    
    func testFetchCalledAndUserUpdatedOnUserIdentityChange() {
        let core = AmplitudeCore.getInstance("integration_test")
        let config = ExperimentConfigBuilder().instanceName("integration_test").build()
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: API_KEY, config: config)
        core.identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["key": "value"]
            ]))
            .commit()
        let user = client.getUser()
        let expectedUser = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .userProperties(["key": "value"])
            .build()
        XCTAssertEqual(user, expectedUser)
    }
    
    func testUserPropertiesMergedOnUserIdentityChange() {
        let core = AmplitudeCore.getInstance("integration_test")
        let config = ExperimentConfigBuilder().instanceName("integration_test").build()
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: API_KEY, config: config)
        core.identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["key": "value"]
            ]))
            .commit()
        core.identityStore.editIdentity()
            .updateUserProperties(NSDictionary(dictionary: [
                "$set": ["other": true]
            ]))
            .commit()
        let user = client.getUser()
        let expectedUser = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .userProperties(["key": "value", "other": true])
            .build()
        XCTAssertEqual(user, expectedUser)
    }
}
