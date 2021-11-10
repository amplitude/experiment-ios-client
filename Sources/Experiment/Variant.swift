//
//  Variant.swift
//  Experiment
//
//  Created by Curtis Liu on 1/20/21.
//

import Foundation

@objc public class Variant : NSObject, Codable {
    
    @objc public let value: String?
    @objc public let payload: Any?

    @objc public init(_ value: String? = nil, payload: Any? = nil) {
        self.value = value
        self.payload = payload
    }

    internal init?(json: [String: Any]) {
        let key = json["key"] as? String
        let value = json["value"] as? String
        if (key == nil && value == nil) {
            return nil
        }
        self.value = (value ?? key)!
        self.payload = json["payload"]
    }
    
    enum CodingKeys: String, CodingKey {
        case value
        case payload
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try values.decode(String.self, forKey: .value)
        if let data = try? values.decode(Data.self, forKey: .payload),
           let objectPayload = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?] {
            self.payload = objectPayload["payload"] ?? nil
        } else {
            self.payload = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        let objectPayload = ["payload": self.payload]
        if let data = try? JSONSerialization.data(withJSONObject: objectPayload, options: []) {
            try container.encode(data, forKey: .payload)
        } else {
            try container.encodeNil(forKey: .payload)
        }
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Variant else {
            return false
        }
        guard self.value == other.value else {
            return false
        }
        if self.payload == nil && other.payload == nil {
            return true
        }
        guard self.payload != nil, other.payload != nil else {
            return false
        }
        if let objectPayload = self.payload as? [String: Any], let otherObjectPayload = self.payload as? [String: Any] {
            return NSDictionary(dictionary: objectPayload).isEqual(to: otherObjectPayload)
        }
        let lhsData = try? JSONEncoder().encode(self)
        let rhsData = try? JSONEncoder().encode(other)
        return lhsData == rhsData
    }
}
