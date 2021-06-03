//
//  ExperimentClientTests.swift
//  ExperimentTests
//
//  Created by Curtis Liu on 12/3/20.
//

import XCTest
@testable import Experiment

let API_KEY = "client-DvWljIjiiuqLbyjqdvBaLFfEBrAvGuA3"
let KEY = "sdk-ci-test"
let INITIAL_KEY = "initial-key"

let testUser = ExperimentUser.Builder().userId("test_user").build()
let serverVariant = Variant("on", payload: "payload")
let fallbackVariant = Variant("fallback", payload: "payload")
let initialVariant = Variant("initial")
let initialVariants: [String: Variant] = [
    INITIAL_KEY: initialVariant,
    KEY: Variant("off")
]

class ExperimentClientTests: XCTestCase {
    
    let client = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig.Builder()
            .debug(true)
            .fallbackVariant(fallbackVariant)
            .initialVariants(initialVariants)
            .build(),
        storage: InMemoryStorage()
    )
    
    let timeoutClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig.Builder()
            .debug(true)
            .fallbackVariant(fallbackVariant)
            .initialVariants(initialVariants)
            .fetchTimeoutMillis(1)
            .build(),
        storage: InMemoryStorage()
    )
    
    let initialVariantSourceClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig.Builder()
            .debug(true)
            .initialVariants(initialVariants)
            .source(.InitialVariants)
            .build(),
        storage: InMemoryStorage()
    )
    
    func testFetch() {
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertEqual(serverVariant, variant)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchTimeout() {
        let s = DispatchSemaphore(value: 0)
        timeoutClient.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY)
            XCTAssertEqual("off", variant.value)
            s.signal()
        }
        s.wait()
    }
    
    func testFallbackVariantReturnedInCorrectOrder() {
        let firstFallback = Variant("first")
        var variant = client.variant("asdf", fallback: firstFallback)
        XCTAssertEqual(firstFallback, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
        
        variant = client.variant("asdf")
        XCTAssertEqual(fallbackVariant, variant)
    }
    
    func testInitialVariantsReturned() {
        let variants = client.all()
        XCTAssertEqual(initialVariants, variants)
    }
    
    func testMergeUserWithProvider() {
        _ = client.setUserProvider(TestContextProvider())
        let user = ExperimentUser.Builder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .build()
        client.setUser(user)
        let mergedUser = client.mergeUserWithProvider()
        let expectedUserAfterMerge = ExperimentUser.Builder()
            .deviceId("device_id")
            .userId(nil)
            .version("version")
            .language("")
            .library("\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)")
            .build()
        XCTAssertEqual(expectedUserAfterMerge, mergedUser)
    }
    
    func testInitialVariantsSourceOverridesFetch() {
        var variant = initialVariantSourceClient.variant(KEY, fallback: nil)
        XCTAssertNotNil(variant)
        let s = DispatchSemaphore(value: 0)
        initialVariantSourceClient.fetch(user: testUser) { (client, error) in
            variant = client.variant(KEY, fallback: nil)
            XCTAssertNotNil(variant)
            XCTAssertEqual("off", variant.value)
            XCTAssertNil(variant.payload)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchSetsUserAndsetUserOverwrites() {
        client.fetch(user: testUser)
        XCTAssertEqual(testUser, client.getUser())
        let newUser = testUser.copyToBuilder().userId("different_user").build()
        client.setUser(newUser)
        XCTAssertEqual(newUser, client.getUser())
    }
}

class TestContextProvider : ExperimentUserProvider {
    func getUser() -> ExperimentUser {
        return ExperimentUser.Builder()
            .deviceId("")
            .version("version2")
            .language("")
            .build()
    }
}
