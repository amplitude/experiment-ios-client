//
//  Experiment.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public class Experiment : NSObject {
    
    private static var defaultInstance = "$default_instance"
    private static var instances: [String: ExperimentClient] = [:]

    @objc public static func initialize(apiKey: String, config: ExperimentConfig) -> ExperimentClient {
        let instance = instances[defaultInstance]
        if (instance != nil) {
            return instance!
        }
        let storage = UserDefaultsStorage(instanceName: defaultInstance, apiKey: apiKey)
        let newInstance: ExperimentClient = DefaultExperimentClient(
            apiKey: apiKey,
            config: config,
            storage: storage
        )
        instances[defaultInstance] = newInstance
        return newInstance
    }
}

internal struct ExperimentError: Error {
    let message: String
    init(_ msg: String) {
        self.message = msg
    }
}
