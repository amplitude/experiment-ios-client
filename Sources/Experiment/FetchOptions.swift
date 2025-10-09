//
//  FetchOptions.swift
//  Experiment
//
//  Copyright © 2022 Amplitude. All rights reserved.
//

import Foundation

@objc public class FetchOptions : NSObject {
    @objc public let flagKeys: [String]?
    @objc public let trackingOption: String?

    @objc public init(_ flagKeys: [String]? = nil, trackingOption: String? = nil) {
        self.flagKeys = flagKeys
        self.trackingOption = trackingOption
    }
}
