//
//  EvaluationIntegrationTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/13/23.
//

import XCTest
import Foundation
@testable import Experiment

private let DEPLOYMENT_KEY = "server-NgJxxvg8OGwwBsWVXqyxQbdiflbhvugy"

nonisolated(unsafe) private var flags: [EvaluationFlag] = []

class EvaluationIntegrationTests: XCTestCase {
    
    let engine = EvaluationEngine()
    
    override class func setUp() {
        flags = try! doFlags()
    }
    
    // Basic Tests
    
    func testOff() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-off"]
        XCTAssertEqual("off", result?.key)
    }
    
    func testOn() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-on"]
        XCTAssertEqual("on", result?.key)
    }
    
    // Opinionated Segment Tests
    
    func testIndividualInclusionsMatch() {
        // Match User ID
        var user = userContext(userId: "user_id")
        var result = engine.evaluate(context: user, flags: flags)["test-individual-inclusions"]
        XCTAssertEqual("on", result?.key)
        XCTAssertEqual("individual-inclusions", result?.metadata?["segmentName"] as! String)
        // Match Device ID
        user = userContext(deviceId: "device_id")
        result = engine.evaluate(context: user, flags: flags)["test-individual-inclusions"]
        XCTAssertEqual("on", result?.key)
        XCTAssertEqual("individual-inclusions", result?.metadata?["segmentName"] as! String)
        // Doesn't Match User ID
        user = userContext(userId: "not_user_id")
        result = engine.evaluate(context: user, flags: flags)["test-individual-inclusions"]
        XCTAssertEqual("off", result?.key)
        // Doesn't Match Device ID
        user = userContext(deviceId: "not_device_id")
        result = engine.evaluate(context: user, flags: flags)["test-individual-inclusions"]
        XCTAssertEqual("off", result?.key)
    }
    
    func testFlagDependenciesOn() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-flag-dependencies-on"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testFlagDependenciesOff() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-flag-dependencies-off"]
        XCTAssertEqual("off", result?.key)
        XCTAssertEqual("flag-dependencies", result?.metadata?["segmentName"] as! String)
    }
    
    func testStickyBucketing() {
        // On
        var user = userContext(userId: "user_id", deviceId: "device_id", userProperties: ["[Experiment] test-sticky-bucketing": "on"])
        var result = engine.evaluate(context: user, flags: flags)["test-sticky-bucketing"]
        XCTAssertEqual("on", result?.key)
        XCTAssertEqual("sticky-bucketing", result?.metadata?["segmentName"] as! String)
        // Off
        user = userContext(userId: "user_id", deviceId: "device_id", userProperties: ["[Experiment] test-sticky-bucketing": "off"])
        result = engine.evaluate(context: user, flags: flags)["test-sticky-bucketing"]
        XCTAssertEqual("off", result?.key)
        XCTAssertEqual("All Other Users", result?.metadata?["segmentName"] as! String)
        // Non-variant
        user = userContext(userId: "user_id", deviceId: "device_id", userProperties: ["[Experiment] test-sticky-bucketing": "not-a-variant"])
        result = engine.evaluate(context: user, flags: flags)["test-sticky-bucketing"]
        XCTAssertEqual("off", result?.key)
    }
    
    func testExperiment() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-experiment"]
        XCTAssertEqual("on", result?.key)
        XCTAssertEqual("exp-1", result?.metadata?["experimentKey"] as! String)
    }
    
    func testFlag() {
        let user = userContext(userId: "user_id", deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-flag"]
        XCTAssertEqual("on", result?.key)
        XCTAssertNil(result?.metadata?["experimentKey"] ?? nil)
    }
    
    // Conditional Logic Tests
    
    func testMultipleConditionsAndValues() {
        // All match, on
        var user = userContext(userProperties: [
            "key-1": "value-1",
            "key-2": "value-2",
            "key-3": "value-3",
        ])
        var result = engine.evaluate(context: user, flags: flags)["test-multiple-conditions-and-values"]
        XCTAssertEqual("on", result?.key)
        // Some match, off
        user = userContext(userProperties: [
            "key-1": "value-1",
            "key-2": "value-2",
        ])
        result = engine.evaluate(context: user, flags: flags)["test-multiple-conditions-and-values"]
        XCTAssertEqual("off", result?.key)
    }
    
    // Condition Property Targeting Tests
    
    func testAmplitudePropertyTargeting() {
        let user = userContext(userId: "user_id")
        let result = engine.evaluate(context: user, flags: flags)["test-amplitude-property-targeting"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testCohortTargeting() {
        // User in cohort
        var user = userContext(cohortIds: ["u0qtvwla", "12345678"])
        var result = engine.evaluate(context: user, flags: flags)["test-cohort-targeting"]
        XCTAssertEqual("on", result?.key)
        // User not in cohort
        user = userContext(cohortIds: ["12345678", "87654321"])
        result = engine.evaluate(context: user, flags: flags)["test-cohort-targeting"]
        XCTAssertEqual("off", result?.key)
    }
    
    func testGroupNameTargeting() {
        let user = groupContext(groupType: "org name", groupName: "amplitude")
        let result = engine.evaluate(context: user, flags: flags)["test-group-name-targeting"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGroupPropertyTargeting() {
        let user = groupContext(groupType: "org name", groupName: "amplitude", groupProperties: ["org plan": "enterprise2"])
        let result = engine.evaluate(context: user, flags: flags)["test-group-property-targeting"]
        XCTAssertEqual("on", result?.key)
    }
    
    // Bucketing Tests
    
    func testAmplitudeIdBucketing() {
        let user = userContext(amplitudeId: "1234567890")
        let result = engine.evaluate(context: user, flags: flags)["test-amplitude-id-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testUserIdBucketing() {
        let user = userContext(userId: "user_id")
        let result = engine.evaluate(context: user, flags: flags)["test-user-id-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testDeviceIdBucketing() {
        let user = userContext(deviceId: "device_id")
        let result = engine.evaluate(context: user, flags: flags)["test-device-id-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testCustomUserPropertyBucketing() {
        let user = userContext(userProperties: ["key": "value"])
        let result = engine.evaluate(context: user, flags: flags)["test-custom-user-property-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGroupNameBucketing() {
        let user = groupContext(groupType: "org name", groupName: "amplitude")
        let result = engine.evaluate(context: user, flags: flags)["test-group-name-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGroupPropertyBucketing() {
        let user = groupContext(groupType: "org name", groupName: "amplitude", groupProperties: ["org plan": "enterprise2"])
        let result = engine.evaluate(context: user, flags: flags)["test-group-property-bucketing"]
        XCTAssertEqual("on", result?.key)
    }
    
    // Bucketing Allocation Tests
    
    func test1PercentAllocation() {
        var on = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-1-percent-allocation" })["test-1-percent-allocation"]
            if result?.key == "on" {
                on += 1
            } else if result?.key != "off" {
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return
            }
        }
        XCTAssertEqual(107, on)
    }
    
    func test50PercentAllocation() {
        var on = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-50-percent-allocation" })["test-50-percent-allocation"]
            if result?.key == "on" {
                on += 1
            } else if result?.key != "off" {
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return
            }
        }
        XCTAssertEqual(5009, on)
    }
    
    func test99PercentAllocation() {
        var on = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-99-percent-allocation" })["test-99-percent-allocation"]
            if result?.key == "on" {
                on += 1
            } else if result?.key != "off" {
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return
            }
        }
        XCTAssertEqual(9900, on)
    }
    
    // Bucketing DistributionTests
    
    func test1PercentDistribution() {
        var control = 0
        var treatment = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-1-percent-distribution" })["test-1-percent-distribution"]
            switch result?.key {
            case "control": control += 1
            case "treatment": treatment += 1
            default:
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return
            }
        }
        XCTAssertEqual(106, control)
        XCTAssertEqual(9894, treatment)
    }
    
    func test50PercentDistribution() {
        var control = 0
        var treatment = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-50-percent-distribution" })["test-50-percent-distribution"]
            switch result?.key {
            case "control": control += 1
            case "treatment": treatment += 1
            default:
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return            }
        }
        XCTAssertEqual(4990, control)
        XCTAssertEqual(5010, treatment)
    }
    
    func test99PercentDistribution() {
        var control = 0
        var treatment = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-99-percent-distribution" })["test-99-percent-distribution"]
            switch result?.key {
            case "control": control += 1
            case "treatment": treatment += 1
            default:
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return            }
        }
        XCTAssertEqual(9909, control)
        XCTAssertEqual(91, treatment)
    }
    
    func testMultipleDistributions() {
        var a = 0
        var b = 0
        var c = 0
        var d = 0
        for i in 0..<10000 {
            let user = userContext(deviceId: "\(i+1)")
            let result = engine.evaluate(context: user, flags: flags.filter { $0.key == "test-multiple-distributions" })["test-multiple-distributions"]
            switch result?.key {
            case "a": a += 1
            case "b": b += 1
            case "c": c += 1
            case "d": d += 1
            default:
                XCTFail("Unexpected variant \(result?.key ?? "nil")")
                return            }
        }
        XCTAssertEqual(2444, a)
        XCTAssertEqual(2634, b)
        XCTAssertEqual(2447, c)
        XCTAssertEqual(2475, d)

    }
    
    // Operator Tests
    
    func testIs() {
        let user = userContext(userProperties: ["key": "value"])
        let result = engine.evaluate(context: user, flags: flags)["test-is"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testIsNot() {
        let user = userContext(userProperties: ["key": "value"])
        let result = engine.evaluate(context: user, flags: flags)["test-is"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testContains() {
        let user = userContext(userProperties: ["key": "value"])
        let result = engine.evaluate(context: user, flags: flags)["test-contains"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testDoesNotContain() {
        let user = userContext(userProperties: ["key": "value"])
        let result = engine.evaluate(context: user, flags: flags)["test-does-not-contain"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testLess() {
        let user = userContext(userProperties: ["key": "-1"])
        let result = engine.evaluate(context: user, flags: flags)["test-less"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testLessOrEqual() {
        let user = userContext(userProperties: ["key": "0"])
        let result = engine.evaluate(context: user, flags: flags)["test-less-or-equal"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGreater() {
        let user = userContext(userProperties: ["key": "1"])
        let result = engine.evaluate(context: user, flags: flags)["test-greater"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGreaterOrEqual() {
        let user = userContext(userProperties: ["key": "0"])
        let result = engine.evaluate(context: user, flags: flags)["test-greater-or-equal"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testVersionLess() {
        let user = ["user": ["version": "1.9.0"]]
        let result = engine.evaluate(context: user, flags: flags)["test-version-less"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testVersionLessOrEqual() {
        let user = ["user": ["version": "1.10.0"]]
        let result = engine.evaluate(context: user, flags: flags)["test-version-less-or-equal"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testVersionGreater() {
        let user = ["user": ["version": "1.10.0"]]
        let result = engine.evaluate(context: user, flags: flags)["test-version-greater"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testVersionGreaterOrEqual() {
        let user = ["user": ["version": "1.9.0"]]
        let result = engine.evaluate(context: user, flags: flags)["test-version-greater-or-equal"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetIs() {
        let user = userContext(userProperties: ["key": ["1", "2", "3"]])
        let result = engine.evaluate(context: user, flags: flags)["test-set-is"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetIsNot() {
        let user = userContext(userProperties: ["key": ["1", "2"]])
        let result = engine.evaluate(context: user, flags: flags)["test-set-is-not"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetContains() {
        let user = userContext(userProperties: ["key": ["1", "2", "3", "4"]])
        let result = engine.evaluate(context: user, flags: flags)["test-set-contains"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetDoesNotContain() {
        let user = userContext(userProperties: ["key": ["1", "2", "4"]])
        let result = engine.evaluate(context: user, flags: flags)["test-set-does-not-contain"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetContainsAny() {
        let user = userContext(cohortIds: ["u0qtvwla", "12345678"])
        let result = engine.evaluate(context: user, flags: flags)["test-set-contains-any"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testSetDoesNotContainAny() {
        let user = userContext(cohortIds: ["12345678", "87654321"])
        let result = engine.evaluate(context: user, flags: flags)["test-set-does-not-contain-any"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGlobMatch() {
        let user = userContext(userProperties: ["key": "/path/1/2/3/end"])
        let result = engine.evaluate(context: user, flags: flags)["test-glob-match"]
        XCTAssertEqual("on", result?.key)
    }
    
    func testGlobDoesNotMatch() {
        let user = userContext(userProperties: ["key": "/path/1/2/3"])
        let result = engine.evaluate(context: user, flags: flags)["test-glob-does-not-match"]
        XCTAssertEqual("on", result?.key)
    }
    
    // Test specific functionality
    
    func testIsWithBooleans() {
        var user = userContext(userProperties: ["true": "TRUE", "false": "FALSE"])
        var result = engine.evaluate(context: user, flags: flags)["test-is-with-booleans"]
        XCTAssertEqual("on", result?.key)
        user = userContext(userProperties: ["true": "True", "false": "False"])
        result = engine.evaluate(context: user, flags: flags)["test-is-with-booleans"]
        XCTAssertEqual("on", result?.key)
        user = userContext(userProperties: ["true": "true", "false": "false"])
        result = engine.evaluate(context: user, flags: flags)["test-is-with-booleans"]
        XCTAssertEqual("on", result?.key)
    }
}

// Object utils

private func userContext(userId: String? = nil, deviceId: String? = nil, amplitudeId: String? = nil, userProperties: [String: Any?]? = nil, cohortIds: [String]? = nil) -> [String: Any?] {
    var user: [String: Any?] = [:]
    if let userId = userId { user["user_id"] = userId }
    if let deviceId = deviceId { user["device_id"] = deviceId }
    if let amplitudeId = amplitudeId { user["amplitude_id"] = amplitudeId }
    if let userProperties = userProperties { user["user_properties"] = userProperties }
    if let cohortIds = cohortIds { user["cohort_ids"] = cohortIds }
    return ["user": user]
}

private func groupContext(groupType: String, groupName: String, groupProperties: [String: Any?]? = nil) -> [String: Any?] {
    return [
        "groups": [
            groupType: [
                "group_name": groupName,
                "group_properties": groupProperties,
            ]  as [String: Any?]
        ] as [String: Any?]
    ] as [String: Any?]
}

// Network utils

private func doFlags() throws -> [EvaluationFlag] {
    var result: Result<[EvaluationFlag], Error>? = nil
    let s = DispatchSemaphore(value: 0)
    try doFlagsAsync { r in
        result = r
        s.signal()
    }
    _ = s.wait(timeout: .now() + .seconds(20))
    switch result {
    case .success(let flags):
        return flags
    case .failure(let error):
        throw error
    default:
        throw ExperimentError("flags response timeout")
    }
}

private func doFlagsAsync(_ completion: @escaping (Result<[EvaluationFlag], Error>) -> Void) throws {
    let url = URL(string: "https://flag.lab.amplitude.com/sdk/v2/flags?eval_mode=remote")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Api-Key \(DEPLOYMENT_KEY)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 20.0
    // Do fetch request
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(Result.failure(error))
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(Result.failure(ExperimentError("Response is nil")))
            return
        }
        guard httpResponse.statusCode == 200 else {
            completion(Result.failure(ExperimentError("Error Response: status=\(httpResponse.statusCode)")))
            return
        }
        guard let data = data else {
            completion(Result.failure(ExperimentError("Flag response data is nil")))
            return
        }
        do {
            let flags = try JSONDecoder().decode([EvaluationFlag].self, from: data)
            completion(Result.success(flags))
        } catch {
            print("[Experiment] Failed to parse flag data: \(error)")
            completion(Result.failure(error))
        }
    }.resume()
}
