//
//  Experiment.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation
import AmplitudeCore

@objc public class Experiment : NSObject {
    
    private static var instancesLock = DispatchSemaphore(value: 1)
    private static var instances: [String: ExperimentClient] = [:]

    @objc public static func initialize(apiKey: String, config: ExperimentConfig) -> ExperimentClient {
        instancesLock.wait()
        defer { instancesLock.signal() }
        let instanceName = config.instanceName
        let instanceKey = "\(instanceName).\(apiKey)"
        let instance = instances[instanceKey]
        if (instance != nil) {
            return instance!
        }
        let storage = UserDefaultsStorage(instanceName: instanceName, apiKey: apiKey)
        let newInstance: ExperimentClient = DefaultExperimentClient(
            apiKey: apiKey,
            config: config,
            storage: storage
        )
        instances[instanceKey] = newInstance
        return newInstance
    }
    
    @objc public static func initializeWithAmplitudeAnalytics(apiKey: String, config: ExperimentConfig = ExperimentConfig()) -> ExperimentClient {
        instancesLock.wait()
        defer { instancesLock.signal() }
        let instanceName = config.instanceName
        let instanceKey = "\(instanceName).\(apiKey)"
        let core = AmplitudeCore.getInstance(instanceName)
        let instance = instances[instanceKey]
        if (instance != nil) {
            return instance!
        }
        let configBuilder = config.copyToBuilder()
        if config.userProvider == nil {
            configBuilder.userProvider(CoreUserProvider(identityStore: core.identityStore))
        }
        if config.analyticsProvider == nil {
            configBuilder.analyticsProvider(CoreAnalyticsProvider(analyticsConnector: core.analyticsConnector))
        }
        let storage = UserDefaultsStorage(instanceName: instanceName, apiKey: apiKey)
        let newInstance: ExperimentClient = DefaultExperimentClient(
            apiKey: apiKey,
            config: configBuilder.build(),
            storage: storage
        )
        instances[instanceKey] = newInstance
        core.identityStore.addIdentityListener(key: "init") { (identity) in
            guard let newUserProperties = identity.userProperties as? [String: Any] else {
                return
            }
            let currentUser = newInstance.getUser() ?? ExperimentUser()
            let userBuilder = currentUser.copyToBuilder()
                .userId(identity.userId)
                .deviceId(identity.deviceId)
            if let currentUserProperties = currentUser.getUserProperties() {
                let mergedUserProperties = newUserProperties.merging(currentUserProperties) { (new, _) in new }
                userBuilder.userProperties(mergedUserProperties)
            } else {
                userBuilder.userProperties(newUserProperties)
            }
            newInstance.fetch(user: userBuilder.build(), completion: nil)
        }
        return newInstance
    }
}

internal struct ExperimentError: Error {
    let message: String
    init(_ msg: String) {
        self.message = msg
    }
}
