//
//  FetchOptions.swift
//  Experiment
//
//  Copyright © 2022 Amplitude. All rights reserved.
//

import Foundation

@objc public class FetchOptions : NSObject, Codable {
    @objc public let flagKeys: [String]?
    @objc public let trackingOption: String?

    @objc public init(_ flagKeys: [String]? = nil, trackingOption: String? = nil) {
        self.flagKeys = flagKeys
        self.trackingOption = trackingOption
    }
    
    private enum CodingKeys: String, CodingKey {
        case flagKeys
        case trackingOption
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flagKeys = try container.decodeIfPresent([String].self, forKey: .flagKeys)
        trackingOption = try container.decodeIfPresent(String.self, forKey: .trackingOption)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(flagKeys, forKey: .flagKeys)
        try container.encodeIfPresent(trackingOption, forKey: .trackingOption)
    }
}
