//
//  SkylabTests.swift
//  SkylabTests
//
//  Created by Curtis Liu on 12/3/20.
//

import XCTest
@testable import Skylab

class SkylabTests: XCTestCase {

    func testGetUserWithContext() {
        let client = DefaultSkylabClient(apiKey: "", config: SkylabConfig())
        _ = client.contextProvider = TestContextProvider()
        client.user = SkylabUser(
            deviceId: "device_id",
            userId: nil,
            version: "version"
        )
        let mergedUser = client.getUserWithContext()
        let expectedUserAfterMerge = SkylabUser(
            deviceId: "device_id",
            userId: nil,
            version: "version",
            language: "language",
            library: "\(SkylabConfig.Constants.Library)/\(SkylabConfig.Constants.Version)"
        )
        XCTAssert(mergedUser == expectedUserAfterMerge)
    }
}

class TestContextProvider : ContextProvider {
    func getDeviceId() -> String? {
        return ""
    }
    func getUserId() -> String? {
        return nil
    }
    func getVersion() -> String? {
        return "version2"
    }
    func getLanguage() -> String? {
        return "language"
    }
    func getPlatform() -> String? {
        return nil
    }
    func getOs() -> String? {
        return nil
    }
    func getDeviceManufacturer() -> String? {
        return nil
    }
    func getDeviceModel() -> String? {
        return nil
    }
}
