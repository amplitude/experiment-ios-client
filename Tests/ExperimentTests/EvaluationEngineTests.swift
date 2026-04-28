//
//  EvaluationEngineTests.swift
//  ExperimentTests
//

import XCTest
@testable import Experiment

class EvaluationEngineTests: XCTestCase {

    let engine = EvaluationEngine()

    // Scalar string tests

    func testScalarStringIsMatch() {
        assertMatch(propValue: "hello", op: EvaluationOperator.IS, values: ["hello"])
    }

    func testScalarStringContainsMatch() {
        assertMatch(propValue: "hello", op: EvaluationOperator.CONTAINS, values: ["ell"])
    }

    func testScalarStringGreaterThanMatch() {
        assertMatch(propValue: "2", op: EvaluationOperator.GREATER_THAN, values: ["1"])
    }

    func testScalarStringIsNoMatch() {
        assertNoMatch(propValue: "world", op: EvaluationOperator.IS, values: ["hello"])
    }

    // Non-string scalar tests

    func testNonStringScalarGreaterThan() {
        assertMatch(propValue: 42, op: EvaluationOperator.GREATER_THAN, values: ["1"])
    }

    func testNonStringScalarIs() {
        assertMatch(propValue: true, op: EvaluationOperator.IS, values: ["true"])
    }

    // JSON array string tests

    func testJsonArrayStringSetOperator() {
        assertMatch(propValue: "[\"a\",\"b\"]", op: EvaluationOperator.SET_CONTAINS, values: ["a"])
    }

    func testJsonArrayStringNonSetOperator() {
        assertMatch(propValue: "[\"a\",\"b\"]", op: EvaluationOperator.IS, values: ["a"])
    }

    // Collection tests

    func testCollectionSetOperator() {
        assertMatch(propValue: ["a", "b"], op: EvaluationOperator.SET_CONTAINS, values: ["a"])
    }

    func testCollectionNonSetOperator() {
        assertMatch(propValue: ["a", "b"], op: EvaluationOperator.IS, values: ["a"])
    }

    // Edge cases

    func testMalformedJsonArrayFallsThrough() {
        assertMatch(propValue: "[broken", op: EvaluationOperator.IS, values: ["[broken"])
    }

    func testEmptyJsonArraySetOperator() {
        assertNoMatch(propValue: "[]", op: EvaluationOperator.SET_CONTAINS, values: ["a"])
    }

    func testLeadingWhitespaceNotParsedAsArray() {
        assertMatch(propValue: " [\"a\"]", op: EvaluationOperator.IS, values: [" [\"a\"]"])
    }

    func testLeadingWhitespaceNotParsedAsArraySet() {
        assertNoMatch(propValue: " [\"a\"]", op: EvaluationOperator.SET_CONTAINS, values: ["a"])
    }
}

// Test helpers

private let testFlagKey = "test-flag"

private func flagWithCondition(op: String, values: Set<String>) -> EvaluationFlag {
    return EvaluationFlag(
        key: testFlagKey,
        variants: ["on": EvaluationVariant(key: "on", value: nil, payload: nil, metadata: nil)],
        segments: [
            EvaluationSegment(
                bucket: nil,
                conditions: [[EvaluationCondition(selector: ["context", "user", "user_properties", "test_prop"], op: op, values: values)]],
                variant: "on",
                metadata: nil
            )
        ],
        dependencies: nil,
        metadata: nil
    )
}

private func contextWithProp(value: Any?) -> [String: Any?] {
    return ["user": ["user_properties": ["test_prop": value]]]
}

private func evaluate(propValue: Any?, op: String, values: Set<String>) -> EvaluationVariant? {
    let flag = flagWithCondition(op: op, values: values)
    let context = contextWithProp(value: propValue)
    let engine = EvaluationEngine()
    let results = engine.evaluate(context: context, flags: [flag])
    return results[testFlagKey]
}

private func assertMatch(propValue: Any?, op: String, values: Set<String>, file: StaticString = #file, line: UInt = #line) {
    let result = evaluate(propValue: propValue, op: op, values: values)
    XCTAssertEqual("on", result?.key, file: file, line: line)
}

private func assertNoMatch(propValue: Any?, op: String, values: Set<String>, file: StaticString = #file, line: UInt = #line) {
    let result = evaluate(propValue: propValue, op: op, values: values)
    XCTAssertNil(result, file: file, line: line)
}
