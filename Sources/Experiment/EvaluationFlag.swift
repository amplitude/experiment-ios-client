//
//  EvaluationFlag.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal struct EvaluationFlag: Codable, Sendable {
    let key: String
    let variants: [String: EvaluationVariant]
    let segments: [EvaluationSegment]
    let dependencies: [String]?
    let metadata: [String: (any Sendable)?]?
}

internal struct EvaluationSegment: Codable, Sendable {
    let bucket: EvaluationBucket?
    let conditions: [[EvaluationCondition]]?
    let variant: String?
    let metadata: [String: (any Sendable)?]?
}

internal struct EvaluationBucket: Codable, Sendable {
    let selector: [String]
    let salt: String
    let allocations: [EvaluationAllocation]
}

internal struct EvaluationCondition: Codable, Sendable {
    let selector: [String]
    let op: String
    let values: Set<String>
}

internal struct EvaluationAllocation: Codable, Sendable {
    let range: [Int]
    let distributions: [EvaluationDistribution]
}

internal struct EvaluationDistribution: Codable, Sendable {
    let variant: String
    let range: [Int]
}

internal struct EvaluationVariant: Codable, Selectable, Sendable {
    let key: String?
    let value: (any Sendable)?
    let payload: (any Sendable)?
    let metadata: [String: (any Sendable)?]?
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

internal extension EvaluationVariant {
    
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

internal extension EvaluationFlag {
    
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
        try? container.encodeIfPresent(dependencies, forKey: .dependencies)
        if let metadata = metadata {
            try? container.encodeIfPresent(AnyEncodable(metadata), forKey: .metadata)
        }
    }
}

internal extension EvaluationSegment {
    
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
        try? container.encodeIfPresent(bucket, forKey: .bucket)
        try? container.encodeIfPresent(conditions, forKey: .conditions)
        try? container.encodeIfPresent(variant, forKey: .variant)
        if let metadata = metadata {
            try? container.encodeIfPresent(AnyEncodable(metadata), forKey: .metadata)
        }
    }
}

internal extension EvaluationVariant {
    
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
        try? container.encodeIfPresent(key, forKey: .key)
        if let value = value {
            try? container.encodeIfPresent(AnyEncodable(value), forKey: .value)
        }
        if let payload = payload {
            try? container.encodeIfPresent(AnyEncodable(payload), forKey: .payload)
        }
        if let metadata = metadata {
            try? container.encodeIfPresent(AnyEncodable(metadata), forKey: .metadata)
        }
    }
}

// Utility Extensions

internal extension EvaluationFlag {
    func isLocalEvaluationMode() -> Bool {
        if let evaluationMode = self.metadata?["evaluationMode"] as? String, evaluationMode == "local" {
            return true
        }
        return false
    }
    func isRemoteEvaluationMode() -> Bool {
        if let evaluationMode = self.metadata?["evaluationMode"] as? String, evaluationMode == "remote" {
            return true
        }
        return false
    }
}
