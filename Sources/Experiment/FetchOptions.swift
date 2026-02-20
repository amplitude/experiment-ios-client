//
//  FetchOptions.swift
//  Experiment
//
//  Copyright © 2022 Amplitude. All rights reserved.
//

import Foundation

@objc public final class FetchOptions : NSObject, Sendable {
    @objc public let flagKeys: [String]?

    @objc public init(_ flagKeys: [String]? = nil) {
        self.flagKeys = flagKeys
    }
}
