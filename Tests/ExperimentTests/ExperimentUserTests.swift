//
//  ExperimentUserTest.swift
//  ExperimentTests
//
//  Created by Brian Giori on 5/5/21.
//

import XCTest
@testable import Experiment

class ExperimentUserTests: XCTestCase {

    let user = ExperimentUserBuilder()
        .deviceId("device_id")
        .userId("user_id")
        .version(nil)
        .country("country")
        .userProperty("stringUserProperty", value: "value")
        .userProperty("intUserProperty", value: 100)
        .userProperty("doubleUserProperty", value: 3.14159)
        .userProperty("boolUserProperty", value: true)
        .userProperty("stringArrayUserProperty", value: ["zero", "one", "two", "three"])
        .userProperty("intArrayUserProperty", value: [0, 1, 2, 3])
        .userProperty("anyArrayUserProperty", value: [0, "one", true, 3.0])
        .build()
    
    let userBulkUserProperties = ExperimentUserBuilder()
        .deviceId("device_id")
        .userId("user_id")
        .version(nil)
        .country("country")
        .userProperties([
            "user_id": "user_id",
            "device_id": "device_id",
            "country": "country",
            "user_properties": [
                "stringUserProperty": "value",
                "intUserProperty": 100,
                "doubleUserProperty": 3.14159,
                "boolUserProperty": true,
                "stringArrayUserProperty": ["zero", "one", "two", "three"],
                "intArrayUserProperty": [0, 1, 2, 3],
                "anyArrayUserProperty": [0, "one", true, 3.0]
            ]
        ])
        .build()
    
    func testExperimentUserJSONSerialization() {
        
        let expectedDictionary: [String : Any] = [
            "user_id": "user_id",
            "device_id": "device_id",
            "country": "country",
            "user_properties": [
                "stringUserProperty": "value",
                "intUserProperty": 100,
                "doubleUserProperty": 3.14159,
                "boolUserProperty": true,
                "stringArrayUserProperty": ["zero", "one", "two", "three"],
                "intArrayUserProperty": [0, 1, 2, 3],
                "anyArrayUserProperty": [0, "one", true, 3.0]
            ]
        ]

        let userData = try! JSONSerialization.data(withJSONObject: user.toDictionary(), options: [])
        let bulkUserData = try! JSONSerialization.data(withJSONObject: user.toDictionary(), options: [])
        let expectedData = try! JSONSerialization.data(withJSONObject: expectedDictionary, options: [])

        let userAnyObject = try! JSONSerialization.jsonObject(with: userData, options: [])
        let bulkUserAnyObject = try! JSONSerialization.jsonObject(with: bulkUserData, options: [])
        let expectedAnyObject = try! JSONSerialization.jsonObject(with: expectedData, options: [])

        let userDict = userAnyObject as! [String:Any]
        let bulkUserDict = bulkUserAnyObject as! [String:Any]
        let expectedDict = expectedAnyObject as! [String:Any]

        let userUserDict = userDict["user_properties"] as! [String:Any]
        let bulkUserUserDict = bulkUserDict["user_properties"] as! [String:Any]
        let expectedUserDict = userDict["user_properties"] as! [String:Any]
        
        XCTAssert(userDict["user_id"] as! String == expectedDict["user_id"] as! String)
        XCTAssert(userDict["device_id"] as! String == expectedDict["device_id"] as! String)
        XCTAssert(userDict["country"] as! String == expectedDict["country"] as! String)
        XCTAssert(NSDictionary(dictionary: userUserDict).isEqual(to: expectedUserDict))
        XCTAssert(NSDictionary(dictionary: bulkUserUserDict).isEqual(to: expectedUserDict))
    }

    func testExperimentUserEquality() {
        let user2 = user.copyToBuilder()
            .userProperty("userPropertyKey", value: "different value")
            .build()
        let user3 = user.copyToBuilder().build()
        print(user)
        print(user2)
        XCTAssert(user != user2)
        XCTAssert(user == user3)
    }

    func testExperimentUserBuilderCopyUser() {
        let user1 = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .country("country")
            .city("test")
            .region("test")
            .dma("test")
            .language("test")
            .platform("test")
            .os("test")
            .library("test")
            .deviceManufacturer("test")
            .deviceModel("test")
            .carrier("test")
            .userProperty("userPropertyKey", value: "value")
            .build()
        let user2 = ExperimentUserBuilder()
            .country("newCountry")
            .version("newVersion")
            .userProperty("userPropertyKey2", value: "value2")
            .build()
        
        let mergedUser = user2.merge(user1)
        let expected = ExperimentUserBuilder()
            .userId("user_id")
            .deviceId("device_id")
            .country("newCountry") // overwrites value
            .version("newVersion") // overwrites null
            .city("test")
            .region("test")
            .dma("test")
            .language("test")
            .platform("test")
            .os("test")
            .library("test")
            .deviceManufacturer("test")
            .deviceModel("test")
            .carrier("test")
            .userProperty("userPropertyKey2", value: "value2")
            .build()
        XCTAssert(expected == mergedUser)
    }
}
