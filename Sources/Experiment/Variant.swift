//
//  Variant.swift
//  Experiment
//
//  Created by Curtis Liu on 1/20/21.
//

import Foundation

@objc public class Variant : NSObject, Codable {
    
    @objc public let key: String?
    @objc public let value: String?
    @objc public let payload: Any?
    @objc public let expKey: String?
    @objc public let metadata: [String: Any]?

    @objc public init(_ value: String? = nil, payload: Any? = nil) {
        self.key = nil
        self.value = value
        self.payload = payload
        self.expKey = nil
        self.metadata = nil
    }
    
    @objc public init(_ value: String? = nil, payload: Any? = nil, expKey: String? = nil) {
        self.key = nil
        self.value = value
        self.payload = payload
        self.expKey = expKey
        self.metadata = nil
    }
    
    @objc public init(_ value: String? = nil, payload: Any? = nil, expKey: String? = nil, key: String? = nil, metadata: [String: Any]? = nil) {
        self.key = key
        self.value = value
        self.payload = payload
        self.expKey = expKey
        self.metadata = metadata
    }
    
    internal init(key: String? = nil, value: String? = nil, payload: Any? = nil, expKey: String? = nil, metadata: [String:Any]? = nil) {
        self.key = key
        self.value = value
        self.payload = payload
        self.expKey = expKey
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case key
        case value
        case payload
        case expKey
        case metadata
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try? values.decode(String.self, forKey: .value)
        self.key = (try? values.decode(String.self, forKey: .key)) ?? self.value

        // The legacy way to encode/decode the payload as a json string where the actual object
        // is the value wrapped inside another json object with a single key, `payload`. And
        // the object is encoded as a base64 string.
        //
        // Check if the payload can be decoded as base64 data, and if the decoded string can be
        // dedcoded to a json object with one key, "payload" which contains the actual json value.
        var payload: Any? = nil
        if let data = try? values.decode(Data.self, forKey: .payload) {
            if let opt = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let objectPayload = opt as? [String: Any?] {
                    if let subPayload = objectPayload["payload"] {
                        payload = subPayload
                    }
                }
            }
        }
        if payload == nil {
            if let anyPayload = try? values.decode(AnyDecodable.self, forKey: .payload) {
                // New way, straight up.
                payload = anyPayload.value
            }
        }
        self.payload = payload

        // Experiment key should always exist in both the explicit field and the metadata.
        let expKey = try? values.decode(String.self, forKey: .expKey)
        let metadataAny = try? values.decode([String: AnyDecodable].self, forKey: .metadata)
        var metadata = metadataAny?.filter { element in element.value.value != nil }.mapValues { anyDecodable in anyDecodable.value! }
        self.expKey = expKey ?? metadata?["experimentKey"] as? String
        if let expKey = self.expKey {
            if metadata != nil {
                metadata?["experimentKey"] = expKey
            } else {
                metadata = ["experimentKey": expKey]
            }
        }
        self.metadata = metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(key, forKey: .key)
        try? container.encodeIfPresent(value, forKey: .value)
        if let payload = payload {
            try? container.encodeIfPresent(AnyEncodable(payload), forKey: .payload)
        }
        try? container.encodeIfPresent(expKey, forKey: .expKey)
        if let metadata = metadata {
            try? container.encodeIfPresent(AnyEncodable(metadata), forKey: .metadata)
        }
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Variant else {
            return false
        }
        guard self.value == other.value else {
            return false
        }
        guard self.expKey == other.expKey else {
            return false
        }
        if self.payload == nil && other.payload == nil {
            return true
        }
        guard self.payload != nil, other.payload != nil else {
            return false
        }
        if let objectPayload = self.payload as? [String: Any], let otherObjectPayload = other.payload as? [String: Any] {
            return NSDictionary(dictionary: objectPayload).isEqual(to: otherObjectPayload)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let lhsData = try? encoder.encode(self)
        let rhsData = try? encoder.encode(other)
        return lhsData == rhsData
    }
    
    @objc override public var description: String {
        return "Variant{key=\(key ?? "nil"), value=\(value ?? "nil"), payload=\(payload ?? "nil"), expKey=\(expKey ?? "nil"), metadata=\(metadata?.description ?? "nil")}"
    }
    
    @objc override public var debugDescription: String {
        return "Variant{key=\(key?.debugDescription ?? "nil"), value=\(value?.debugDescription ?? "nil"), payload=\(payload.debugDescription), expKey=\(expKey ?? "nil"), metadata=\(metadata?.debugDescription ?? "nil")}"
    }
}

// Utility extensions

internal extension Variant {
    
    func isDefaultVariant() -> Bool {
        if let isDefault = metadata?["default"] as? Bool {
            return isDefault
        }
        return false
    }
    
    func isEmpty() -> Bool {
        return key == nil && value == nil && payload == nil && expKey == nil && metadata == nil
    }
}
