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
let userDefaults = UserDefaults.standard
let userDefaultsKey = "com.amplituide.experiment.variants.\(instance).\(apiKey)"

class UserDefaultsStorageTests: XCTestCase {
    
    let storage = UserDefaultsStorage(instanceName: instance, apiKey: apiKey)
    let variants: [String: Variant] = [
        "variant1": Variant("1", payload: 1),
        "variant2": Variant("2", payload: "2"),
        "variant3": Variant("3", payload: nil),
        "variant4": Variant("4", payload: [4, 4, 4]),
        "variant5": Variant("5", payload: ["k":"v"]),
        "variant6": Variant("6", payload: true),
        "variant7": Variant("7", payload: 6.9)
    ]
    func testLoadAndGetAll() {
        preload(variants)
        storage.load()
        let storageVariants = storage.getAll()
        XCTAssertEqual(variants, storageVariants)
    }
    
    func testPutSaveAndGetAll() {
        for (key, variant) in variants {
            storage.put(key: key, value: variant)
        }
        storage.save()
        let storageVariants = storage.getAll()
        XCTAssertEqual(variants, storageVariants)
        storage.load()
        let storageVariants2 = storage.getAll()
        XCTAssertEqual(variants, storageVariants2)
        XCTAssertEqual(storageVariants, storageVariants2)
    }
    
    func testLoadNilStorage() {
        userDefaults.set(nil, forKey: userDefaultsKey)
        storage.load()
        print(storage.getAll())
    }
    
    func testClear() {
        preload(variants)
        storage.load()
        storage.clear()
        let empty = storage.getAll()
        XCTAssertTrue(empty.isEmpty)
        storage.load()
        let storageVariants = storage.getAll()
        XCTAssertEqual(variants, storageVariants)
    }
    
    func preload(_ variants: [String: Variant]) {
        let data = try! JSONEncoder().encode(variants)
        userDefaults.set(data, forKey: userDefaultsKey)
    }
}
