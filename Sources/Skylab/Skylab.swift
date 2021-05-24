//
//  Skylab.swift
//  Skylab
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public class Skylab {
    static var instances: [String: SkylabClient] = [:]

    public static func getInstance() -> SkylabClient? {
        return getInstance(SkylabConfig.Defaults.InstanceName)
    }

    public static func getInstance(_ name: String) -> SkylabClient? {
        return instances[name]
    }

    public static func initialize(apiKey: String, config: SkylabConfig) -> SkylabClient {
        let instance = getInstance(config.instanceName)
        if (instance != nil) {
            return instance!
        }
        let newInstance: SkylabClient = DefaultSkylabClient(apiKey: apiKey, config: config)
        instances[config.instanceName] = newInstance
        return newInstance
    }
}
