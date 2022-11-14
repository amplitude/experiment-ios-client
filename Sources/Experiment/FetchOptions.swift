//
//  FetchOptions.swift
//  Experiment
//
//  Copyright © 2022 Amplitude. All rights reserved.
//

import Foundation

@objc public class Variant : NSObject {
    @objc public let flagKeys: [String]?

    @objc public init(_ flagKeys: [String]? = nil) {
        self.flagKeys = flagKeys
    }
}
