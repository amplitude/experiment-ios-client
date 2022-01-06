//
//  IdentityStoreTests.swift
//  AmplitudeCoreTests
//
//  Created by Brian Giori on 12/22/21.
//

import XCTest
@testable import AmplitudeCore

class IdentityStoreTests: XCTestCase {
    
    func testEditIdentitySetUserIdSetDeviceIdGetIdentitySuccess() {
        let expectedIdentity = Identity(userId: "user_id", deviceId: "device_id")
        let identityStore = IdentityStoreImpl()
        identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .commit()
        let identity = identityStore.getIdentity()
        XCTAssertEqual(expectedIdentity, identity)
    }
    
    func testEditIdentitysetUserIdSetDeviceIdIdentityListenerCalled() {
        let expectedIdentity = Identity(userId: "user_id", deviceId: "device_id")
        let identityStore = IdentityStoreImpl()
        var actualIdentity: Identity? = nil
        identityStore.addIdentityListener(key: "test") { (identity) in
            actualIdentity = identity
        }
        identityStore.editIdentity()
            .setUserId("user_id")
            .setDeviceId("device_id")
            .commit()
        XCTAssertEqual(expectedIdentity, actualIdentity)
    }
    
    func testSetIdentityGetIdentitySuccess() {
        let expectedIdentity = Identity(userId: "user_id", deviceId: "device_id")
        let identityStore = IdentityStoreImpl()
        identityStore.setIdentity(expectedIdentity)
        let actualIdentity = identityStore.getIdentity()
        XCTAssertEqual(expectedIdentity, actualIdentity)
    }
    
    func testSetIdentityIdentityListenerCalled() {
        let expectedIdentity = Identity(userId: "user_id", deviceId: "device_id")
        let identityStore = IdentityStoreImpl()
        var actualIdentity: Identity? = nil
        identityStore.addIdentityListener(key: "test") { (identity) in
            actualIdentity = identity
        }
        identityStore.setIdentity(expectedIdentity)
        XCTAssertEqual(expectedIdentity, actualIdentity)
    }
    
    func testSetIdentityWithUnchangedIdentityIdentityListenerNotCalled() {
        let expectedIdentity = Identity(userId: "user_id", deviceId: "device_id")
        let identityStore = IdentityStoreImpl()
        identityStore.setIdentity(expectedIdentity)
        identityStore.addIdentityListener(key: "test") { (identity) in
            XCTFail("listener should not be called when identity does not change")
        }
        identityStore.setIdentity(expectedIdentity)
    }
    
    func testUpdateUserPropertiesSet() {
        let expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf(["key1": "value1"]))
        let identityStore = IdentityStoreImpl()
        identityStore.editIdentity()
            .updateUserProperties(mapOf([
                "$set": ["key1": "value1"]
            ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesUnset() {
        let expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": "value"
        ]))
        let identityStore = IdentityStoreImpl()
        identityStore.setIdentity(Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": "value",
            "other": true,
            "final": 4.2
        ])))
        identityStore.editIdentity()
            .updateUserProperties(mapOf([
                "$unset": ["other": "-", "final": "-"]
            ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesSetOnce() {
        let expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": "value"
        ]))
        let identityStore = IdentityStoreImpl()
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$setOnce": ["key": "value"]
        ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$setOnce": ["key": "value2"]
        ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesAdd() {
        let identityStore = IdentityStoreImpl()
        var expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf(["int": 10, "double":3.14]))
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$add": ["int": 10, "double": 3.14]
        ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
        expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf(["int": 20, "double": 6.28]))
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$add": ["int": 10, "double": 3.14]
        ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesAppend() {
        let identityStore = IdentityStoreImpl()
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$append": ["key": [-3, -2, -1]]
        ])).commit()
        var expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": [-3, -2, -1]
        ]))
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
        identityStore.editIdentity().updateUserProperties(mapOf([
           "$append": ["key": [0, 1, 2, 3]]
        ])).commit()
        expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": [-3, -2, -1, 0, 1, 2, 3]
        ]))
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesPrepend() {
        let identityStore = IdentityStoreImpl()
        identityStore.editIdentity().updateUserProperties(mapOf([
           "$prepend": ["key": [0, 1, 2, 3]]
        ])).commit()
        var expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": [0, 1, 2, 3]
        ]))
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$prepend": ["key": [-3, -2, -1]]
        ])).commit()
        expectedIdentity = Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": [-3, -2, -1, 0, 1, 2, 3]
        ]))
        XCTAssertEqual(identityStore.getIdentity(), expectedIdentity)
    }
    
    func testUpdateUserPropertiesClearAll() {
        let identityStore = IdentityStoreImpl()
        identityStore.setIdentity(Identity(userId: nil, deviceId: nil, userProperties: mapOf([
            "key": "value",
            "other": true,
            "number": 20
        ])))
        identityStore.editIdentity().updateUserProperties(mapOf([
            "$clearAll": [:]
        ])).commit()
        XCTAssertEqual(identityStore.getIdentity(), Identity())
    }
}

private func mapOf(_ d: [AnyHashable: Any] = [:]) -> NSDictionary {
    return NSDictionary(dictionary: d)
}

private func arrayOf(_ a: [Any]) -> NSArray {
    return NSArray(array: a)
}
