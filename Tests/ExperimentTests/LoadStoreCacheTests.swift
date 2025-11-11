//
//  LoadStoreCacheTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/26/23.
//

import AmplitudeCore
import Foundation
import XCTest
@testable import Experiment

class LoadStoreCacheTests: XCTestCase {
    
    func testCacheMethods() {
        let storage = InMemoryStorage()
        let cache = LoadStoreCache<Variant>(namespace: "test", storage: storage, logger: AmpLogger(logLevel: LogLevel.debug, loggerProvier: DefaultLogger()))
        // Put / Get
        cache.put(key: "flag-key-1", value: Variant(key: "on", value: "on"))
        let variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(Variant(key: "on", value: "on"), variant)
        // Put All / Get All
        cache.putAll(values: [
            "flag-key-2": Variant(key: "on", value: "on"),
            "flag-key-3": Variant(key: "on", value: "on")
        ])
        var variants = cache.getAll()
        XCTAssertEqual([
            "flag-key-1": Variant(key: "on", value: "on"),
            "flag-key-2": Variant(key: "on", value: "on"),
            "flag-key-3": Variant(key: "on", value: "on")
        ], variants)
        // Delete
        cache.remove(key: "flag-key-3")
        variants = cache.getAll()
        XCTAssertEqual([
            "flag-key-1": Variant(key: "on", value: "on"),
            "flag-key-2": Variant(key: "on", value: "on")
        ], variants)
        // Clear
        cache.clear()
        variants = cache.getAll()
        XCTAssertEqual([:], variants)
    }
    
    func testLoad() {
        let namespace = "test"
        let storage = InMemoryStorage()
        let cache = LoadStoreCache<Variant>(namespace: namespace, storage: storage, logger: AmpLogger(logLevel: LogLevel.debug, loggerProvier: DefaultLogger()))
        let testData = """
        {"flag-key-1":{"key":"on","value":"on"}}
        """.data(using: .utf8)!
        storage.put(key: namespace, value: testData)
        var variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(nil, variant)
        cache.load()
        variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(Variant(key: "on", value: "on"), variant)
    }
    
    func testLoadOverwritesCache() {
        let namespace = "test"
        let storage = InMemoryStorage()
        let cache = LoadStoreCache<Variant>(namespace: namespace, storage: storage, logger: AmpLogger(logLevel: LogLevel.debug, loggerProvier: DefaultLogger()))
        let testData = """
        {"flag-key-1":{"key":"off","value":"off"}}
        """.data(using: .utf8)!
        storage.put(key: namespace, value: testData)
        cache.put(key: "flag-key-1", value: Variant(key: "on", value: "on"))
        var variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(Variant(key: "on", value: "on"), variant)
        cache.load()
        variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(Variant(key: "off", value: "off"), variant)
        storage.delete(key: namespace)
        cache.load()
        variant = cache.get(key: "flag-key-1")
        XCTAssertEqual(nil, variant)
    }
    
    func testStore() {
        let namespace = "test"
        let storage = InMemoryStorage()
        let cache = LoadStoreCache<Variant>(namespace: namespace, storage: storage, logger: AmpLogger(logLevel: LogLevel.debug, loggerProvier: DefaultLogger()))
        cache.put(key: "flag-key-1", value: Variant(key: "on", value: "on"))
        cache.store(async: false)
        let storageData = storage.get(key: namespace)
        let storageVariants = try! JSONDecoder().decode([String:Variant].self, from: storageData!)
        let expectedVariants = ["flag-key-1": Variant(key: "on", value: "on")]
        XCTAssertEqual(expectedVariants, storageVariants)
    }
    
    func testStoreOverwritesStorage() {
        let namespace = "test"
        let storage = InMemoryStorage()
        let cache = LoadStoreCache<Variant>(namespace: namespace, storage: storage, logger: AmpLogger(logLevel: LogLevel.debug, loggerProvier: DefaultLogger()))
        let initialData = """
        {"flag-key-1":{"key":"on","value":"on"}}
        """.data(using: .utf8)!
        storage.put(key: namespace, value: initialData)
        cache.put(key: "flag-key-1", value: Variant(key: "off", value: "off"))
        cache.store(async: false)
        var storageData = storage.get(key: namespace)
        var storageVariants = try! JSONDecoder().decode([String:Variant].self, from: storageData!)
        var expectedVariants = ["flag-key-1": Variant(key: "off", value: "off")]
        XCTAssertEqual(expectedVariants, storageVariants)
        cache.clear()
        cache.store(async: false)
        storageData = storage.get(key: namespace)
        storageVariants = try! JSONDecoder().decode([String:Variant].self, from: storageData!)
        expectedVariants = [:]
        XCTAssertEqual(expectedVariants, storageVariants)
    }
}
