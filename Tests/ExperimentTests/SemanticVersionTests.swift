//
//  SemanticVersionTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/12/23.
//

import XCTest
import Foundation
@testable import Experiment

class SemanticVersionTests : XCTestCase {
    
    func testInvalidVersions() {
        // just major
        assertInvalidVersion("10")
        // trailing dots
        assertInvalidVersion("10.")
        assertInvalidVersion("10..")
        assertInvalidVersion("10.2.")
        assertInvalidVersion("10.2.33.")
        // trailing dots on prerelease tags are not handled because prerelease tags are considered
        // strings anyway for comparison which should be fine - e.g. "10.2.33-alpha1.2."

        // dots in the middle
        assertInvalidVersion("10..2.33")
        assertInvalidVersion("102...33")

        // invalid characters
        assertInvalidVersion("a.2.3")
        assertInvalidVersion("23!")
        assertInvalidVersion("23.#5")
        assertInvalidVersion("")
        assertInvalidVersion(nil)

        // more numbers
        assertInvalidVersion("2.3.4.567")
        assertInvalidVersion("2.3.4.5.6.7")

        // prerelease if provided should always have major, minor, patch
        assertInvalidVersion("10.2.alpha")
        assertInvalidVersion("10.alpha")
        assertInvalidVersion("alpha-1.2.3")

        // prerelease should be separated by a hyphen after patch
        assertInvalidVersion("10.2.3alpha")
        assertInvalidVersion("10.2.3alpha-1.2.3")

        // negative numbers
        assertInvalidVersion("-10.1")
        assertInvalidVersion("10.-1")
    }
    
    func testValidVersions() {
        assertValidVersion("100.2")
        assertValidVersion("0.102.39")
        assertValidVersion("0.0.0")

        // versions with leading 0s would be converted to int
        assertValidVersion("01.02")
        assertValidVersion("001.001100.000900")

        // prerelease tags
        assertValidVersion("10.20.30-alpha")
        assertValidVersion("10.20.30-1.x.y")
        assertValidVersion("10.20.30-aslkjd")
        assertValidVersion("10.20.30-b894")
        assertValidVersion("10.20.30-b8c9")
    }
    
    func testVersionComparison() {
        // EQUALS case
        assertVersionComparison("66.12.23", EvaluationOperator.IS, "66.12.23")
        // patch if not specified equals 0
        assertVersionComparison("5.6", EvaluationOperator.IS, "5.6.0")
        // leading 0s are not stored when parsed
        assertVersionComparison("06.007.0008", EvaluationOperator.IS, "6.7.8")
        // with pre release
        assertVersionComparison("1.23.4-b-1.x.y", EvaluationOperator.IS, "1.23.4-b-1.x.y")

        // DOES NOT EQUAL case
        assertVersionComparison("1.23.4-alpha-1.2", EvaluationOperator.IS_NOT, "1.23.4-alpha-1")
        // trailing 0s aren't stripped
        assertVersionComparison("1.2.300", EvaluationOperator.IS_NOT, "1.2.3")
        assertVersionComparison("1.20.3", EvaluationOperator.IS_NOT, "1.2.3")

        // LESS THAN case
        // patch of .1 makes it greater
        assertVersionComparison("50.2", EvaluationOperator.VERSION_LESS_THAN, "50.2.1")
        // minor 9 > minor 20
        assertVersionComparison("20.9", EvaluationOperator.VERSION_LESS_THAN, "20.20")
        // same version with pre release should be lesser
        assertVersionComparison("20.9.4-alpha1", EvaluationOperator.VERSION_LESS_THAN, "20.9.4")
        // compare prerelease as strings
        assertVersionComparison("20.9.4-a-1.2.3", EvaluationOperator.VERSION_LESS_THAN, "20.9.4-a-1.3")
        // since prerelease is compared as strings a1.23 < a1.5 because 2 < 5
        assertVersionComparison("20.9.4-a1.23", EvaluationOperator.VERSION_LESS_THAN, "20.9.4-a1.5")

        // GREATER THAN case
        assertVersionComparison("12.30.2", EvaluationOperator.VERSION_GREATER_THAN, "12.4.1")
        // 100 > 1
        assertVersionComparison("7.100", EvaluationOperator.VERSION_GREATER_THAN, "7.1")
        // 10 > 9
        assertVersionComparison("7.10", EvaluationOperator.VERSION_GREATER_THAN, "7.9")
        // converts to 7.10.20 > 7.9.1
        assertVersionComparison("07.010.0020", EvaluationOperator.VERSION_GREATER_THAN, "7.009.1")
        // patch comparison comes first
        assertVersionComparison("20.5.6-b1.2.x", EvaluationOperator.VERSION_GREATER_THAN, "20.5.5")
    }
}

func assertInvalidVersion(_ versionString: String?) {
    guard SemanticVersion.parse(version: versionString) != nil else {
        // expect null
        return
    }
    XCTFail("Should have failed creating a semantic version for \(versionString ?? "nil")")
}

func assertValidVersion(_ versionString: String) {
    if SemanticVersion.parse(version: versionString) == nil {
        XCTFail("Expected a non null semantic version for \(versionString)")
    }
}

func assertVersionComparison(_ v1: String, _ op: String, _ v2: String) {
    guard let sv1 = SemanticVersion.parse(version: v1) else {
        XCTFail("parsing should succeed: \(v1)")
        return
    }
    guard let sv2 = SemanticVersion.parse(version: v2) else {
        XCTFail("parsing should succeed: \(v2)")
        return
    }
    switch (op) {
    case EvaluationOperator.IS:
        XCTAssertTrue(sv1 == sv2)
        break
    case EvaluationOperator.IS_NOT:
        XCTAssertTrue(sv1 != sv2)
        break
    case EvaluationOperator.VERSION_LESS_THAN:
        XCTAssertTrue(sv1 < sv2)
        break
    case EvaluationOperator.VERSION_GREATER_THAN:
        XCTAssertTrue(sv1 > sv2)
        break
    default:
        XCTFail("unexpected op \(op)")
    }
}
