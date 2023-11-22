//
//  VariantTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 6/29/21.
//

import XCTest
@testable import Experiment


let encoder = JSONEncoder()
let decoder = JSONDecoder()

let payloadObjectJson = """
{"testing":123,"repeat":[1,2,3],"ok":true}
"""
let payloadObject = try! JSONSerialization.jsonObject(with: payloadObjectJson.data(using: .utf8)!, options: [])

let payloadArrayJson = """
["testing","testing",123]
"""
let payloadArray = try! JSONSerialization.jsonObject(with: payloadArrayJson.data(using: .utf8)!, options: [])

let variantNullPayload = Variant("testNull", payload: nil)
let variantStringPayload = Variant("testString", payload: "test", key: "testString")
let variantIntPayload = Variant("testInt", payload: 69, key: "testInt")
let variantDoublePayload = Variant("testDouble", payload: 6.9, key: "testDouble")
let variantBoolPayload = Variant("testBool", payload: true, key: "testBool")
let variantObjectPayload = Variant("testObject", payload: payloadObject, key: "testObject")
let variantArrayPayload = Variant("testArray", payload: payloadArray, key: "testArray")

class VariantTests: XCTestCase {

    func testVariantNullPayload() {
        let original = variantNullPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        XCTAssertNil(decoded.payload)
    }
    
    func testVariantStringPayload() {
        let original = variantStringPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = original.payload as! String
        let decodedPayload = decoded.payload as! String
        XCTAssertEqual(decodedPayload, originalPayload)
    }
    
    func testVariantIntPayload() {
        let original = variantIntPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = original.payload as! Int
        let decodedPayload = decoded.payload as! Int
        XCTAssertEqual(decodedPayload, originalPayload)
    }
    
    func testVariantDoublePayload() {
        let original = variantDoublePayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = original.payload as! Double
        let decodedPayload = decoded.payload as! Double
        XCTAssertEqual(decodedPayload, originalPayload)
    }
    
    func testVariantBoolPayload() {
        let original = variantBoolPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = original.payload as! Bool
        let decodedPayload = decoded.payload as! Bool
        XCTAssertEqual(decodedPayload, originalPayload)
    }
    
    func testVariantObjectPayload() {
        let original = variantObjectPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = original.payload as! [String:Any]
        let decodedPayload = decoded.payload as! [String:Any]
        XCTAssertEqual(NSDictionary(dictionary: originalPayload), NSDictionary(dictionary: decodedPayload))
    }
    
    func testVariantArrayPayload() {
        let original = variantArrayPayload
        print("-------------\noriginal: \(original)")
        let encoded = try! encoder.encode(original)
        print("encoded: \(String(data: encoded, encoding: .utf8)!)")
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        print("decoded: \(decoded)")
        XCTAssertEqual(decoded, original)
        let originalPayload = try! JSONEncoder().encode(AnyEncodable(original.payload as! [Any?]))
        let decodedPayload = try! JSONEncoder().encode(AnyEncodable(decoded.payload as! [Any?]))
        XCTAssertEqual(decodedPayload.description, originalPayload.description)
    }
    
    func testVariantExpeirmentKey() {
        let variantMap = """
            {"value":"value","expKey":"expKey"}
        """.data(using: .utf8)!
        let variantFromMap = try! decoder.decode(Variant.self, from: variantMap)
        let variant = Variant("value", payload: nil, expKey: "expKey")
        XCTAssertEqual(variant, variantFromMap)
        let encoded = try! encoder.encode(variant)
        let decoded = try! decoder.decode(Variant.self, from: encoded)
        XCTAssertEqual(decoded, variant)
    }
    
    // V1 -> V2 variant encoding transformation tests
    
    func testV1VariantTransformation() {
        let rawVariant = """
            {"value":"on"}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "on", value: "on"), variant)
    }
    
    func testV1VariantTransformationWithNewPayload() {
        let rawVariant = """
            {"value":"on", "payload":{"k":"v"}}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "on", value: "on", payload: ["k":"v"]), variant)
    }
    
    func testV1VariantTransformationWithOldPayload() {
        let rawVariant = """
        {"value":"on", "payload":"eyJwYXlsb2FkIjp7ImsiOiJ2In19"}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "on", value: "on", payload: ["k":"v"]), variant)
    }
    
    func testV1VariantTransformationWithPayloadAndExperimentKey() {
        let rawVariant = """
            {"value":"on", "payload":{"k":"v"}, "expKey":"exp-1"}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "on", value: "on", payload: ["k":"v"], expKey: "exp-1"), variant)
        XCTAssertEqual("exp-1", variant.metadata?["experimentKey"] as! String)
    }
    
    // Test V2 encoding and decoding
    
    func testV2VariantTransformation() {
        let rawVariant = """
            {"key":"treatment", "value":"on"}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "treatment", value: "on"), variant)
    }
    
    func testV2VariantTransformationWithExperimentKeyMetadata() {
        let rawVariant = """
            {"key":"treatment", "value":"on", "metadata":{"experimentKey":"exp-1"}}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "treatment", value: "on", expKey: "exp-1", metadata: ["experimentKey":"exp-1"]), variant)
    }
    func testV2VariantTransformationWithExperimentKeyExplicit() {
        let rawVariant = """
            {"key":"treatment", "value":"on", "expKey":"exp-1"}
        """.data(using: .utf8)!
        let variant = try! JSONDecoder().decode(Variant.self, from: rawVariant)
        XCTAssertEqual(Variant(key: "treatment", value: "on", expKey: "exp-1", metadata: ["experimentKey":"exp-1"]), variant)
    }
}
