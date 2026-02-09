//
//  Experiment.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation
import AnalyticsConnector

@objc public class Experiment : NSObject {
    
    private nonisolated(unsafe) static var instancesLock = DispatchSemaphore(value: 1)
    private nonisolated(unsafe) static var instances: [String: ExperimentClient] = [:]

    @objc public static func initialize(apiKey: String, config: ExperimentConfig) -> ExperimentClient {
        instancesLock.wait()
        defer { instancesLock.signal() }
        let instanceName = config.instanceName
        let instanceKey = "\(instanceName).\(apiKey)"
        let instance = instances[instanceKey]
        if (instance != nil) {
            return instance!
        }
        let storage = UserDefaultsStorage()
        let newInstance: ExperimentClient = DefaultExperimentClient(
            apiKey: apiKey,
            config: config,
            storage: storage
        )
        instances[instanceKey] = newInstance
        return newInstance
    }
    
    /// Initialize experiment with a built in integration with your Amplitude Analytics SDK.
    ///
    /// You *must* use Amplitude-iOS version v8.8.0+ for this integration to work.
    @objc public static func initializeWithAmplitudeAnalytics(apiKey: String, config: ExperimentConfig = ExperimentConfig()) -> ExperimentClient {
        instancesLock.wait()
        defer { instancesLock.signal() }
        let instanceName = config.instanceName
        let instanceKey = "\(instanceName).\(apiKey)"
        let connector = AnalyticsConnector.getInstance(instanceName)
        let instance = instances[instanceKey]
        if (instance != nil) {
            return instance!
        }
        let configBuilder = config.copyToBuilder()
        if config.userProvider == nil {
            configBuilder.userProvider(ConnectorUserProvider(identityStore: connector.identityStore))
        }
        if config.exposureTrackingProvider == nil {
            configBuilder.exposureTrackingProvider(ConnectorExposureTrackingProvider(eventBridge:  connector.eventBridge))
        }
        let storage = UserDefaultsStorage()
        let newInstance: ExperimentClient = DefaultExperimentClient(
            apiKey: apiKey,
            config: configBuilder.build(),
            storage: storage
        )
        instances[instanceKey] = newInstance
        if config.automaticFetchOnAmplitudeIdentityChange {
            connector.identityStore.addIdentityListener(key: "init") { (identity) in
                newInstance.fetch(user: ExperimentUser(), completion: nil)
            }
        }
        return newInstance
    }
}

internal struct ExperimentError: Error, Sendable {
    let message: String
    init(_ msg: String) {
        self.message = msg
    }
}

internal struct FetchError: Error, Sendable {
    let statusCode: Int
    let message: String

    init(_ statusCode: Int, _ msg: String) {
        self.statusCode = statusCode
        self.message = msg
    }
}
