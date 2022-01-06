//
//  AmplitudeCoreTests.swift
//  AmplitudeCoreTests
//
//  Created by Brian Giori on 12/21/21.
//

import XCTest
@testable import AmplitudeCore

class AmplitudeCoreTests: XCTestCase {
    
    func testGetInstanceReturnsSameInstance() {
        let core1 = AmplitudeCore.getInstance("test")
        let core2 = AmplitudeCore.getInstance("test")
        XCTAssertEqual(core1, core2)
    }
    
    func testGetInstanceWithDifferentNamesGetsDifferentInstances() {
        let core1 = AmplitudeCore.getInstance("test1")
        let core2 = AmplitudeCore.getInstance("tett2")
        XCTAssertNotEqual(core1, core2)
    }
}
