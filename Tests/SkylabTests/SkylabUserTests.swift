//
//  SkylabUserTest.swift
//  SkylabTests
//
//  Created by Brian Giori on 5/5/21.
//

import XCTest
@testable import Skylab

class SkylabUserTests: XCTestCase {

    func testSkylabUserJSONSerialization() {
        let user = SkylabUser(
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

    func testSkylabUserEquality() {
        let user = SkylabUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "value"]
        )
        let user2 = SkylabUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "different value"]
        )
        let user3 = SkylabUser(
            deviceId: "device_id",
            userId: "user_id",
            version: nil,
            country: "country",
            userProperties: ["userPropertyKey": "value"]
        )
        XCTAssert(user != user2)
        XCTAssert(user == user3)
    }

    func testSkylabUserBuilderCopyUser() {
        let builder = SkylabUser.Builder()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .setCountry("country")
            .setCity("test")
            .setRegion("test")
            .setDma("test")
            .setLanguage("test")
            .setPlatform("test")
            .setOs("test")
            .setLibrary("test")
            .setDeviceFamily("test")
            .setDeviceType("test")
            .setDeviceManufacturer("test")
            .setDeviceModel("test")
            .setCarrier("test")
            .setUserProperty("userPropertyKey", value: "value")
        let user2 = SkylabUser.Builder()
            .setCountry("newCountry")
            .setVersion("newVersion")
            .setUserProperty("userPropertyKey2", value: "value2")
            .build()
        let user = builder.copyUser(user2).build()
        let expected = SkylabUser.Builder()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .setCountry("newCountry") // overwrites value
            .setVersion("newVersion") // overwrites null
            .setCity("test")
            .setRegion("test")
            .setDma("test")
            .setLanguage("test")
            .setPlatform("test")
            .setOs("test")
            .setLibrary("test")
            .setDeviceFamily("test")
            .setDeviceType("test")
            .setDeviceManufacturer("test")
            .setDeviceModel("test")
            .setCarrier("test")
            .setUserProperty("userPropertyKey2", value: "value2")
            .build()
        XCTAssert(expected == user)
    }
}
