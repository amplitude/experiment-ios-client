//
//  ExperimentUserTest.swift
//  ExperimentTests
//
//  Created by Brian Giori on 5/5/21.
//

import XCTest
@testable import Experiment

class ExperimentUserTests: XCTestCase {

    func testExperimentUserJSONSerialization() {
        let user = ExperimentUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "value"]
        )
        let expectedDictionary: [String : Any] = [
            "user_id": "user_id",
            "device_id": "device_id",
            "country": "country",
            "user_properties": [
                "userPropertyKey": "value"
            ]
        ]

        let userData = try! JSONSerialization.data(withJSONObject: user.toDictionary(), options: [])
        let expectedData = try! JSONSerialization.data(withJSONObject: expectedDictionary, options: [])

        let userAnyObject = try! JSONSerialization.jsonObject(with: userData, options: [])
        let expectedAnyObject = try! JSONSerialization.jsonObject(with: expectedData, options: [])

        let userDict = userAnyObject as! [String:Any]
        let expectedDict = expectedAnyObject as! [String:Any]

        let userUserDict = userDict["user_properties"] as! [String:String]
        let expectedUserDict = userDict["user_properties"] as! [String:String]

        XCTAssert(userDict["user_id"] as! String == expectedDict["user_id"] as! String)
        XCTAssert(userDict["device_id"] as! String == expectedDict["device_id"] as! String)
        XCTAssert(userDict["country"] as! String == expectedDict["country"] as! String)
        XCTAssert(userUserDict == expectedUserDict)
    }

    func testExperimentUserEquality() {
        let user = ExperimentUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "value"]
        )
        let user2 = ExperimentUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "different value"]
        )
        let user3 = ExperimentUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "value"]
        )
        XCTAssert(user != user2)
        XCTAssert(user == user3)
    }

    func testExperimentUserBuilderCopyUser() {
        let user1 = ExperimentUser.Builder()
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
        let user2 = ExperimentUser.Builder()
            .country("newCountry")
            .version("newVersion")
            .userProperty("userPropertyKey2", value: "value2")
            .build()
        
        let mergedUser = user2.merge(user1)
        let expected = ExperimentUser.Builder()
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
