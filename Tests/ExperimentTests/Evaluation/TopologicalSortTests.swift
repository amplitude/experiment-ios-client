//
//  TopologicalSortTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/13/23.
//

import XCTest
import Foundation


class TopologicalSortTests: XCTestCase {
    
    func testEmpty() throws {
        let flagConfigs: [EvaluationFlag] = []
        var result = try topologicalSort(flagConfigs)
        XCTAssertTrue(result.count == 0)
        result = try topologicalSort(flagConfigs, keys: [1])
        XCTAssertTrue(result.count == 0)
    }
    
    func testSingleFlagNoDependencies() throws {
        let dependencies: [Int] = []
        let flagConfigs = [flag(1, dependencies)]
        // No flag keys
        var result = try topologicalSort(flagConfigs)
        XCTAssertEqual([flag(1, dependencies)], result)
        // With flag keys
        result = try topologicalSort(flagConfigs, keys: [1])
        XCTAssertEqual([flag(1, dependencies)], result)
        // With flag keys, no match
        result = try topologicalSort(flagConfigs, keys: [999])
        XCTAssertEqual([], result)
    }
    
    func testSingleFlagWithDependencies() throws {
        let dependencies: [Int] = [2]
        let flagConfigs = [flag(1, dependencies)]
        // No flag keys
        var result = try topologicalSort(flagConfigs)
        XCTAssertEqual([flag(1, dependencies)], result)
        // With flag keys
        result = try topologicalSort(flagConfigs, keys: [1])
        XCTAssertEqual([flag(1, dependencies)], result)
        // With flag keys, no match
        result = try topologicalSort(flagConfigs, keys: [999])
        XCTAssertEqual([], result)
    }
    
    func testMultipleFlagsNoDependencies() throws {
        let dependencies: [Int] = []
        let flagConfigs = [
            flag(1, dependencies),
            flag(2, dependencies)
        ]
        // No flag keys
        var result = try topologicalSort(flagConfigs)
        XCTAssertEqual([
            flag(1, dependencies),
            flag(2, dependencies)
        ], result)
        // With flag keys
        result = try topologicalSort(flagConfigs, keys: [1, 2])
        XCTAssertEqual([
            flag(1, dependencies),
            flag(2, dependencies)
        ], result)
        // With flag keys, no match
        result = try topologicalSort(flagConfigs, keys: [99, 999])
        XCTAssertEqual([], result)
    }
    
    func testMultipleFlagsWithDependencies() throws {
        let flagConfigs = [
            flag(1, [2]),
            flag(2, [3]),
            flag(3, []),
        ]
        // No flag keys
        var result = try topologicalSort(flagConfigs)
        XCTAssertEqual([
            flag(3, []),
            flag(2, [3]),
            flag(1, [2]),
        ], result)
        // With flag keys
        result = try topologicalSort(flagConfigs, keys: [1, 2])
        XCTAssertEqual([
            flag(3, []),
            flag(2, [3]),
            flag(1, [2]),
        ], result)
        // With flag keys, no match
        result = try topologicalSort(flagConfigs, keys: [99, 999])
        XCTAssertEqual([], result)
    }
    
    func testSingleFlagCycle() throws {
        let flagConfigs = [flag(1, [1])]
        // No flag keys
        do {
            _ = try topologicalSort(flagConfigs)
            XCTFail("Expected cylce")
        } catch is CycleError {
            // Success
        }
        // With flag keys
        do {
            _ = try topologicalSort(flagConfigs, keys: [1])
            XCTFail("Expected cylce")
        } catch is CycleError {
            // Success
        }
        // With flag keys, not match
        _ = try topologicalSort(flagConfigs, keys: [999])
    }
    
    func testTwoFlagCycle() throws {
        let flagConfigs = [
            flag(1, [2]),
            flag(2, [1])
        ]
        // No flag keys
        do {
            _ = try topologicalSort(flagConfigs)
            XCTFail("Expected cylce")
        } catch is CycleError {
            // Success
        }
        // With flag keys
        do {
            _ = try topologicalSort(flagConfigs, keys: [2])
            XCTFail("Expected cylce")
        } catch is CycleError {
            // Success
        }
        // With flag keys, not match
        _ = try topologicalSort(flagConfigs, keys: [999])
    }
    
    func testMultipleFlagsComplexCylcle() throws {
        let flagConfigs = [
            flag(3, [1, 2]),
            flag(1, []),
            flag(4, [21, 3]),
            flag(2, []),
            flag(5, [3]),
            flag(6, []),
            flag(7, []),
            flag(8, [9]),
            flag(9, []),
            flag(20, [4]),
            flag(21, [20]),
        ]
        do {
            // Force iteration order
            let keys = flagConfigs.map { flag in Int(flag.key)! }
            _ = try topologicalSort(flagConfigs, keys: keys)
            XCTFail("Expected cylce")
        } catch is CycleError {
            // Success
        }
    }
    
    func testTopologicalSortComplexNoCycle_startWithLeaf() throws {
        let flags = [
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(3, [6, 5]),
            flag(4, [8, 7]),
            flag(5, [10, 7]),
            flag(7, [8]),
            flag(6, [7, 4]),
            flag(8, []),
            flag(9, [10, 7, 5]),
            flag(10, [7]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ]
        // Force iteration order
        let keys = flags.map { flag in Int(flag.key)! }
        let result = try topologicalSort(flags, keys: keys)
        XCTAssertEqual([
            flag(8, []),
            flag(7, [8]),
            flag(4, [8, 7]),
            flag(6, [7, 4]),
            flag(10, [7]),
            flag(5, [10, 7]),
            flag(3, [6, 5]),
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(9, [10, 7, 5]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ], result)
    }
    
    func testTopologicalSortComplexNoCycle_startWithMiddle() throws {
        let flags = [
            flag(6, [7, 4]),
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(3, [6, 5]),
            flag(4, [8, 7]),
            flag(5, [10, 7]),
            flag(7, [8]),
            flag(8, []),
            flag(9, [10, 7, 5]),
            flag(10, [7]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ]
        // Force iteration order
        let keys = flags.map { flag in Int(flag.key)! }
        let result = try topologicalSort(flags, keys: keys)
        XCTAssertEqual([
            flag(8, []),
            flag(7, [8]),
            flag(4, [8, 7]),
            flag(6, [7, 4]),
            flag(10, [7]),
            flag(5, [10, 7]),
            flag(3, [6, 5]),
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(9, [10, 7, 5]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ], result)
    }
    
    func testTopologicalSortComplexNoCycle_startWithRoot() throws {
        let flags = [
            flag(8, []),
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(3, [6, 5]),
            flag(4, [8, 7]),
            flag(5, [10, 7]),
            flag(7, [8]),
            flag(6, [7, 4]),
            flag(9, [10, 7, 5]),
            flag(10, [7]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ]
        // Force iteration order
        let keys = flags.map { flag in Int(flag.key)! }
        let result = try topologicalSort(flags, keys: keys)
        XCTAssertEqual([
            flag(8, []),
            flag(7, [8]),
            flag(4, [8, 7]),
            flag(6, [7, 4]),
            flag(10, [7]),
            flag(5, [10, 7]),
            flag(3, [6, 5]),
            flag(1, [6, 3]),
            flag(2, [8, 5, 3, 1]),
            flag(9, [10, 7, 5]),
            flag(20, []),
            flag(21, [20]),
            flag(30, []),
        ], result)
    }
}

// Utils

extension EvaluationFlag : Equatable {
    static func == (lhs: EvaluationFlag, rhs: EvaluationFlag) -> Bool {
        return lhs.key == rhs.key
    }
}

func flag(_ key: Int, _ dependencies: [Int]) -> EvaluationFlag {
    return EvaluationFlag(
        key: String(key),
        variants: [:],
        segments: [],
        dependencies: Set(dependencies.map { i in
            String(i)
        }),
        metadata: nil
    )
}

func topologicalSort(_ flags: [EvaluationFlag], keys: [Int]? = nil) throws -> [EvaluationFlag] {
    var flagMap: [String: EvaluationFlag] = [:]
    for flag in flags {
        flagMap[flag.key] = flag
    }
    if let flagKeys = keys {
        return try topologicalSort(flags: flagMap, flagKeys: flagKeys.map { i in String(i) }, sorted: true)
    } else {
        return try topologicalSort(flags: flagMap, sorted: true)
    }
}
