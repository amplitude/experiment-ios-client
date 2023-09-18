//
//  EvaluationFlag.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal struct EvaluationFlag: Codable {
    let key: String
    let variants: [String: EvaluationVariant]
    let segments: [EvaluationSegment]
    let dependencies: [String]?
    let metadata: [String: Any?]?
}

internal struct EvaluationSegment: Codable {
    let bucket: EvaluationBucket?
    let conditions: [[EvaluationCondition]]?
    let variant: String?
    let metadata: [String: Any?]?
}

internal struct EvaluationBucket: Codable {
    let selector: [String]
    let salt: String
    let allocations: [EvaluationAllocation]
}

internal struct EvaluationCondition: Codable {
    let selector: [String]
    let op: String
    let values: Set<String>
}

internal struct EvaluationAllocation: Codable {
    let range: [Int]
    let distributions: [EvaluationDistribution]
}

internal struct EvaluationDistribution: Codable {
    let variant: String
    let range: [Int]
}

internal struct EvaluationVariant: Codable, Selectable {
    let key: String?
    let value: Any?
    let payload: Any?
    let metadata: [String: Any?]?
}

internal class EvaluationOperator {
    static let IS = "is"
    static let IS_NOT = "is not"
    static let CONTAINS = "contains"
    static let DOES_NOT_CONTAIN = "does not contain"
    static let LESS_THAN = "less"
    static let LESS_THAN_EQUALS = "less or equal"
    static let GREATER_THAN = "greater"
    static let GREATER_THAN_EQUALS = "greater or equal"
    static let VERSION_LESS_THAN = "version less"
    static let VERSION_LESS_THAN_EQUALS = "version less or equal"
    static let VERSION_GREATER_THAN = "version greater"
    static let VERSION_GREATER_THAN_EQUALS = "version greater or equal"
    static let SET_IS = "set is"
    static let SET_IS_NOT = "set is not"
    static let SET_CONTAINS = "set contains"
    static let SET_DOES_NOT_CONTAIN = "set does not contain"
    static let SET_CONTAINS_ANY = "set contains any"
    static let SET_DOES_NOT_CONTAIN_ANY = "set does not contain any"
    static let REGEX_MATCH = "regex match"
    static let REGEX_DOES_NOT_MATCH = "regex does not match"
}

// Selectable Extensions

extension EvaluationVariant {
    
    func select(selector: String) -> Any? {
        switch selector {
        case "key": return key
        case "value": return value
        case "payload": return payload
        case "metadata": return metadata
        default: return nil
        }
    }
}

// Codable Extensions

extension EvaluationFlag {
    
    enum CodingKeys: CodingKey {
        case key
        case variants
        case segments
        case dependencies
        case metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.variants = try container.decode([String: EvaluationVariant].self, forKey: .variants)
        self.segments = try container.decode([EvaluationSegment].self, forKey: .segments)
        self.dependencies = try? container.decode([String].self, forKey: .dependencies)
        let metadata = try? container.decode([String: AnyDecodable].self, forKey: .metadata)
        self.metadata = metadata?.mapValues { anyDecodable in anyDecodable.value }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(variants, forKey: .variants)
        try container.encode(segments, forKey: .segments)
        try? container.encode(dependencies, forKey: .dependencies)
        try? container.encode(AnyEncodable(metadata), forKey: .metadata)
    }
}

extension EvaluationSegment {
    
    enum CodingKeys: CodingKey {
        case bucket
        case conditions
        case variant
        case metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bucket = try? container.decode(EvaluationBucket.self, forKey: .bucket)
        self.conditions = try? container.decode([[EvaluationCondition]].self, forKey: .conditions)
        self.variant = try? container.decode(String.self, forKey: .variant)
        let metadata = try? container.decode([String: AnyDecodable].self, forKey: .metadata)
        self.metadata = metadata?.mapValues { anyDecodable in anyDecodable.value }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(bucket, forKey: .bucket)
        try? container.encode(conditions, forKey: .conditions)
        try? container.encode(variant, forKey: .variant)
        try? container.encode(AnyEncodable(metadata), forKey: .metadata)
    }
}

extension EvaluationVariant {
    
    enum CodingKeys: CodingKey {
        case key
        case value
        case payload
        case metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try? container.decode(String.self, forKey: .key)
        self.value = try? container.decode(AnyDecodable.self, forKey: .value).value
        self.payload = try? container.decode(AnyDecodable.self, forKey: .payload).value
        let metadata = try? container.decode([String: AnyDecodable].self, forKey: .metadata)
        self.metadata = metadata?.mapValues { anyDecodable in anyDecodable.value }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(key, forKey: .key)
        try? container.encode(AnyEncodable(value), forKey: .value)
        try? container.encode(AnyEncodable(payload), forKey: .payload)
        try? container.encode(AnyEncodable(metadata), forKey: .metadata)
    }
}

// Any Codable

private struct AnyDecodable: Decodable {
    
    public let value: Any?

    public init<T>(_ value: T?) {
        if value is NSNull {
            self.value = nil
        } else {
            self.value = value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyDecodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyDecodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

private struct AnyEncodable: Encodable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let number as NSNumber:
            try encode(nsnumber: number, into: &container)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [Any?]:
            try container.encode(array.map { AnyEncodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyEncodable($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }

    private func encode(nsnumber: NSNumber, into container: inout SingleValueEncodingContainer) throws {
        switch Character(Unicode.Scalar(UInt8(nsnumber.objCType.pointee)))  {
        case "B":
            try container.encode(nsnumber.boolValue)
        case "c":
            try container.encode(nsnumber.int8Value)
        case "s":
            try container.encode(nsnumber.int16Value)
        case "i", "l":
            try container.encode(nsnumber.int32Value)
        case "q":
            try container.encode(nsnumber.int64Value)
        case "C":
            try container.encode(nsnumber.uint8Value)
        case "S":
            try container.encode(nsnumber.uint16Value)
        case "I", "L":
            try container.encode(nsnumber.uint32Value)
        case "Q":
            try container.encode(nsnumber.uint64Value)
        case "f":
            try container.encode(nsnumber.floatValue)
        case "d":
            try container.encode(nsnumber.doubleValue)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled")
            throw EncodingError.invalidValue(nsnumber, context)
        }
    }
}

