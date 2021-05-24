//
//  Experiment.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public class Experiment {
    static var instances: [String: ExperimentClient] = [:]

    public static func getInstance() -> ExperimentClient? {
        return getInstance(ExperimentConfig.Defaults.InstanceName)
    }

    public static func getInstance(_ name: String) -> ExperimentClient? {
        return instances[name]
    }

    public static func initialize(apiKey: String, config: ExperimentConfig) -> ExperimentClient {
        let instance = getInstance(config.instanceName)
        if (instance != nil) {
            return instance!
        }
        let newInstance: ExperimentClient = DefaultExperimentClient(apiKey: apiKey, config: config)
        instances[config.instanceName] = newInstance
        return newInstance
    }
}
