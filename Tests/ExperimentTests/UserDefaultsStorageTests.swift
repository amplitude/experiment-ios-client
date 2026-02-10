//
//  UserDefaultsTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 6/29/21.
//

import XCTest
@testable import Experiment

let instance = "test"
let apiKey = "123456"
nonisolated(unsafe) let userDefaults = UserDefaults.standard
let userDefaultsKey = "com.amplituide.experiment.variants.\(instance).\(apiKey)"

nonisolated(unsafe) let storage = UserDefaultsStorage()

class UserDefaultsStorageTests: XCTestCase {
    
    override class func tearDown() {
        storage.delete(key: userDefaultsKey)
    }
    
    override func setUp() {
        storage.delete(key: userDefaultsKey)
    }
    
    func testAllMethods() {
        let data = "data".data(using: .utf8)!
        storage.put(key: userDefaultsKey, value: data)
        var value = storage.get(key: userDefaultsKey)
        XCTAssertEqual(data, value)
        storage.delete(key: userDefaultsKey)
        value = storage.get(key: userDefaultsKey)
        XCTAssertEqual(nil, value)
    }
}
