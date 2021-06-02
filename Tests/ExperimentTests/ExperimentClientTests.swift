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
let ON_VARIANT_VALUE = "on"
let ON_VARIANT_PAYLOAD = "payload"

let testUser = ExperimentUser(userId: "test_user")
let fallbackVariant = Variant("fallback", payload: "payload")
let initialVariants: [String: Variant] = [
    "initial1": Variant("initial1", payload: ["abc":"cdf"]),
    "initial2": Variant("initial2"),
    KEY: Variant("off")
]

class ExperimentClientTests: XCTestCase {
    
    let client = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig(
            debug: true,
            fallbackVariant: fallbackVariant,
            initialVariants: initialVariants
        ),
        storage: InMemoryStorage()
    )
    
    let timeoutClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig(
            debug: true,
            fallbackVariant: fallbackVariant,
            initialVariants: initialVariants,
            fetchTimeoutMillis: 1
        ),
        storage: InMemoryStorage()
    )
    
    let initialVariantSourceClient = DefaultExperimentClient(
        apiKey: API_KEY,
        config: ExperimentConfig(
            debug: true,
            fallbackVariant: fallbackVariant,
            initialVariants: initialVariants,
            source: Source.InitialVariants
        ),
        storage: InMemoryStorage()
    )
    
    func testFetch() {
        let s = DispatchSemaphore(value: 0)
        client.fetch(user: testUser) { (client, error) in
            XCTAssertNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertNotNil(variant)
            XCTAssertEqual(ON_VARIANT_VALUE, variant?.value)
            XCTAssertEqual(ON_VARIANT_PAYLOAD, variant?.payload as? String)
            s.signal()
        }
        s.wait()
    }
    
    func testFetchTimeout() {
        let s = DispatchSemaphore(value: 0)
        timeoutClient.fetch(user: testUser) { (client, error) in
            XCTAssertNotNil(error)
            let variant = client.variant(KEY, fallback: nil)
            XCTAssertEqual("off", variant?.value)
            s.signal()
        }
        s.wait()
    }
    
    func testFallbackVariantReturnedInCorrectOrder() {
        let firstFallback = Variant("first")
        var variant = client.variant("asdf", fallback: firstFallback)
        XCTAssertEqual(firstFallback, variant)
        variant = client.variant("asdf", fallback: nil)
        XCTAssertEqual(fallbackVariant, variant)
    }
    
    func testInitialVariantsReturned() {
        let variants = client.all()
        XCTAssertEqual(initialVariants, variants)
    }
    
    func testMergeUserWithProvider() {
        _ = client.setUserProvider(TestContextProvider())
        client.setUser(ExperimentUser(
            deviceId: "device_id",
            userId: nil,
            version: "version"
        ))
        let mergedUser = client.mergeUserWithProvider()
        let expectedUserAfterMerge = ExperimentUser(
            deviceId: "device_id",
            userId: nil,
            version: "version",
            language: "",
            library: "\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)"
        )
        XCTAssertEqual(expectedUserAfterMerge, mergedUser)
    }
    
    func testInitialVariantsSourceOverridesFetch() {
        var variant = initialVariantSourceClient.variant(KEY, fallback: nil)
        XCTAssertNotNil(variant)
        let s = DispatchSemaphore(value: 0)
        initialVariantSourceClient.fetch(user: testUser) { (client, error) in
            variant = client.variant(KEY, fallback: nil)
            XCTAssertNotNil(variant)
            XCTAssertEqual("off", variant?.value)
            XCTAssertNil(variant?.payload)
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
