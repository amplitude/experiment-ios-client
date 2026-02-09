//
//  FetchOptions.swift
//  Experiment
//
//  Copyright © 2022 Amplitude. All rights reserved.
//

import Foundation

/// - Note: Uses @unchecked Sendable due to @objc compatibility requirements.
///   All properties are immutable (`let`).
@objc public class FetchOptions : NSObject, @unchecked Sendable {
    @objc public let flagKeys: [String]?

    @objc public init(_ flagKeys: [String]? = nil) {
        self.flagKeys = flagKeys
    }
}
