//
//  SkylabConfig.swift
//  Skylab
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public struct SkylabConfig {
    public let debug: Bool
    public let debugAssignmentRequests: Bool
    public let fallbackVariant: Variant?
    public let initialFlags: [String: Variant]
    public let instanceName: String
    public let serverUrl: String

    public init(
        debug: Bool = SkylabConfig.Defaults.Debug,
        debugAssignmentRequests: Bool = SkylabConfig.Defaults.DebugAssignmentRequests,
        fallbackVariant: Variant? = SkylabConfig.Defaults.FallbackVariant,
        initialFlags: [String: Variant] = SkylabConfig.Defaults.InitialFlags,
        instanceName: String = SkylabConfig.Defaults.InstanceName,
        serverUrl: String = SkylabConfig.Defaults.ServerUrl
    ) {
        self.debug = debug
        self.debugAssignmentRequests = debugAssignmentRequests
        self.fallbackVariant = fallbackVariant
        self.initialFlags = initialFlags
        self.instanceName = instanceName
        self.serverUrl = serverUrl
    }

    public struct Defaults {
        public static let Debug: Bool = false
        public static let DebugAssignmentRequests: Bool = false
        public static let FallbackVariant: Variant? = nil
        public static let InitialFlags: [String: Variant] = [:]
        public static let InstanceName: String = ""
        public static let ServerUrl: String = "https://api.lab.amplitude.com"
    }

    public struct Constants {
        // Version string is matched in release.config.js
        // Changing this may result in breaking automated releases
        public static let Version: String = "1.1.0"
        public static let Library: String = "skylab-ios"
    }
}
