//
//  Murmur3Tests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 9/11/23.
//

import XCTest
import Foundation
@testable import Experiment

let MURMUR_SEED = 0x7f3a21ea

class Murmur3Tests: XCTestCase {
    
    func testMurmur3HashSimple() {
        let input = "brian"
        let result = input.murmurHash32x86(seed: MURMUR_SEED)
        XCTAssertEqual(result, 3948467465)
    }
    
    func testMurmur3EnglishWords() {
        let inputs = ENGLISH_WORDS.split(separator: "\n")
        let outputs = MURMUR3_X86_32.split(separator: "\n")
        for i in 0..<inputs.count {
            let input = String(inputs[i])
            let output = Int(outputs[i])
            let result = input.murmurHash32x86(seed: MURMUR_SEED)
            XCTAssertEqual(result, output)
        }
    }
    
    func testUnicodeStrings() {
        XCTAssertEqual("My hovercraft is full of eels.".murmurHash32x86(seed: 0), 2953494853)
        XCTAssertEqual("My 🚀 is full of 🦎.".murmurHash32x86(seed: 0), 1818098979)
        XCTAssertEqual("吉 星 高 照".murmurHash32x86(seed: 0), 3435142074)
    }
}
