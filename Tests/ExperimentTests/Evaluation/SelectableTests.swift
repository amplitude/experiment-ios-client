//
//  SelectableTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/12/23.
//

import XCTest
import Foundation

class SelectableTests: XCTestCase {
    
    let baseObject: [String: Any?] = [
        "nil": nil,
        "string": "value",
        "int": 13,
        "double": 13.12,
        "boolean": true,
        "array": [1, 2, 3],
    ]
    
    let object: [String: Any?] = [
        "nil": nil,
        "string": "value",
        "int": 13,
        "double": 13.12,
        "boolean": true,
        "array": [1, 2, 3],
        "object": [
            "nil": nil,
            "string": "value",
            "int": 13,
            "double": 13.12,
            "boolean": true,
            "array": [1, 2, 3],
        ] as [String: Any?]
    ]
    
    func testSelectableEvaluationContextTypes() {
        XCTAssertNil(object.select(selector: ["does", "not", "exist"]))
        XCTAssertNil(object.select(selector: ["object", "does", "not", "exist"]))

        XCTAssertNil(object.select(selector: ["nil"]))
        XCTAssertNil(object.select(selector: ["object", "nil"]))
        
        XCTAssertEqual("value", object.select(selector: ["string"]) as! String)
        XCTAssertEqual("value", object.select(selector: ["object", "string"]) as! String)
        
        XCTAssertEqual(13, object.select(selector: ["int"]) as! Int)
        XCTAssertEqual(13, object.select(selector: ["object", "int"]) as! Int)
        
        XCTAssertEqual(13.12, object.select(selector: ["double"]) as! Double)
        XCTAssertEqual(13.12, object.select(selector: ["object", "double"]) as! Double)
        
        XCTAssertEqual(true, object.select(selector: ["boolean"]) as! Bool)
        XCTAssertEqual(true, object.select(selector: ["object", "boolean"]) as! Bool)
        
        XCTAssertEqual([1, 2, 3], object.select(selector: ["array"]) as! Array<Int>)
        XCTAssertEqual([1, 2, 3], object.select(selector: ["object", "array"]) as! Array<Int>)
    }
}
