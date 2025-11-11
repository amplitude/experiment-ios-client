//
//  Excperiment.swift
//  experiment-ios-client
//
//  Created by Chris Leonavicius on 3/18/25.
//

import AmplitudeCore
import Foundation

@objc
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class ExperimentPlugin: NSObject, UniversalPlugin {

    @objc(ExperimentPluginConfig)
    @objcMembers
    public class Config : NSObject {

        public var deploymentKey: String?
        public var debug: Bool
        public var fallbackVariant: Variant
        public var initialFlags: String?
        public var initialVariants: [String: Variant]
        public var source: Source
        public var serverUrl: String
        public var flagsServerUrl: String
        public var fetchTimeoutMillis: Int
        public var retryFetchOnFailure: Bool
        public var automaticExposureTracking: Bool
        public var fetchOnStart: NSNumber? // objc cant do nil boolean values, use nsnumber
        public var pollOnStart: Bool
        public var flagConfigPollingIntervalMillis: Int
        public var automaticFetchOnAmplitudeIdentityChange: Bool

        public convenience override init() {
            self.init(deploymentKey: nil)
        }

        public init(deploymentKey: String? = nil,
                    debug: Bool = ExperimentConfig.Defaults.debug,
                    fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant,
                    initialFlags: String? = ExperimentConfig.Defaults.initialFlags,
                    initialVariants: [String : Variant] = ExperimentConfig.Defaults.initialVariants,
                    source: Source = ExperimentConfig.Defaults.source,
                    serverUrl: String = ExperimentConfig.Defaults.serverUrl,
                    flagsServerUrl: String = ExperimentConfig.Defaults.flagsServerUrl,
                    fetchTimeoutMillis: Int = ExperimentConfig.Defaults.fetchTimeoutMillis,
                    retryFetchOnFailure: Bool = ExperimentConfig.Defaults.retryFetchOnFailure,
                    automaticExposureTracking: Bool = ExperimentConfig.Defaults.automaticExposureTracking,
                    fetchOnStart: NSNumber? = ExperimentConfig.Defaults.fetchOnStart,
                    pollOnStart: Bool = ExperimentConfig.Defaults.pollOnStart,
                    flagConfigPollingIntervalMillis: Int = ExperimentConfig.Defaults.flagConfigPollingIntervalMillis,
                    automaticFetchOnAmplitudeIdentityChange: Bool = ExperimentConfig.Defaults.automaticFetchOnAmplitudeIdentityChange) {
            self.deploymentKey = deploymentKey
            self.debug = debug
            self.fallbackVariant = fallbackVariant
            self.initialFlags = initialFlags
            self.initialVariants = initialVariants
            self.source = source
            self.serverUrl = serverUrl
            self.flagsServerUrl = flagsServerUrl
            self.fetchTimeoutMillis = fetchTimeoutMillis
            self.retryFetchOnFailure = retryFetchOnFailure
            self.automaticExposureTracking = automaticExposureTracking
            self.fetchOnStart = fetchOnStart
            self.pollOnStart = pollOnStart
            self.flagConfigPollingIntervalMillis = flagConfigPollingIntervalMillis
            self.automaticFetchOnAmplitudeIdentityChange = automaticFetchOnAmplitudeIdentityChange
        }
    }

    static let pluginName: String = "com.amplitude.experiment"

    @objc public var experiment: ExperimentClient?

    private enum ExperimentClientMode {
        case hosted(config: Config)
        case external
    }

    private let mode: ExperimentClientMode
    private var context: AmplitudeContext?
    private var analytics: (any AnalyticsClient)?
    private var logger: CoreLogger?

    public var name: String? {
        switch mode {
        case .hosted(config: let config):
            return Self.instanceName(deploymentKey: config.deploymentKey)
        case .external:
            if let experiment = experiment as? DefaultExperimentClient {
                return Self.instanceName(deploymentKey: experiment.apiKey)
            } else {
                return nil
            }
        }
    }

    // Dedup instances by deployment key.
    // A nil deployment key means we should use the API key of the analytics client we attach to.
    // But this may not be available as the client may not be attached
    // So we indicate this by deduping just on pluginName, as api key should be consistent
    // per analytics client
    fileprivate static func instanceName(deploymentKey: String?) -> String {
        if let deploymentKey {
            return pluginName + "_" + deploymentKey
        } else {
            return pluginName
        }
    }

    @objc public init(config: Config = .init()) {
        mode = .hosted(config: config)
    }

    @objc public init(experiment: ExperimentClient) {
        mode = .external
        self.experiment = experiment
    }

    public func setup(analyticsClient: any AmplitudeCore.AnalyticsClient,
                      amplitudeContext: AmplitudeCore.AmplitudeContext) {
        self.context = amplitudeContext
        self.analytics = analyticsClient
        self.logger = amplitudeContext.logger

        switch mode {
        case .hosted(let config):
            let configBuilder = ExperimentConfigBuilder()
            configBuilder.debug = config.debug
            configBuilder.instanceName = amplitudeContext.instanceName
            configBuilder.fallbackVariant = config.fallbackVariant
            configBuilder.initialFlags = config.initialFlags
            configBuilder.initialVariants = config.initialVariants
            configBuilder.source = config.source
            configBuilder.serverUrl = config.serverUrl
            configBuilder.flagsServerUrl = config.flagsServerUrl
            let serverZone: ServerZone
            switch amplitudeContext.serverZone {
            case .US:
                serverZone = .US
            case .EU:
                serverZone = .EU
            @unknown default:
                serverZone = .US
            }
            configBuilder.serverZone = serverZone
            configBuilder.fetchTimeoutMillis = config.fetchTimeoutMillis
            configBuilder.retryFetchOnFailure = config.retryFetchOnFailure
            configBuilder.automaticExposureTracking = config.automaticExposureTracking
            configBuilder.fetchOnStart = config.fetchOnStart
            configBuilder.pollOnStart = config.pollOnStart
            configBuilder.flagConfigPollingIntervalMillis = config.flagConfigPollingIntervalMillis
            configBuilder.automaticFetchOnAmplitudeIdentityChange = config.automaticFetchOnAmplitudeIdentityChange
            configBuilder.userProvider = self
            configBuilder.exposureTrackingProvider = self

            experiment = Experiment.initialize(apiKey: config.deploymentKey ?? amplitudeContext.apiKey,
                                               config: configBuilder.build())
        case .external:
            break
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ExperimentPlugin: ExperimentUserProvider {

    public func getUser() -> ExperimentUser {
        let userBuilder = ExperimentUserBuilder()

        if let analytics {
            let identity = analytics.identity
            userBuilder.deviceId = identity.deviceId
            userBuilder.userId = identity.userId
            userBuilder.userPropertiesAnyValue = identity.userProperties
        }

        return userBuilder.build()


/*
 TODO: add support for additional properties:
        internal var version: String?
        internal var country: String?
        internal var region: String?
        internal var dma: String?
        internal var city: String?
        internal var language: String?
        internal var platform: String?
        internal var os: String?
        internal var deviceManufacturer: String?
        internal var deviceModel: String?
        internal var carrier: String?
        internal var library: String?
        internal var groups: [String: [String]]?
        internal var groupProperties: [String: [String: [String: Any]]]?
 */

    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ExperimentPlugin: ExposureTrackingProvider {

    public func track(exposure: Exposure) {
        guard let analytics else {
            logger?.error(message: "Attempted to send exposure event from disconnected plugin")
            return
        }
        var eventProperties = [String: Any]()
        eventProperties["flag_key"] = exposure.flagKey
        eventProperties["variant"] = exposure.variant
        eventProperties["experiment_key"] = exposure.experimentKey
        eventProperties["metadata"] = exposure.metadata
        analytics.track(eventType: "$exposure", eventProperties: eventProperties)
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension PluginHost {

    public func experiment(apiKey: String?) -> ExperimentClient? {
        return (plugin(name: ExperimentPlugin.instanceName(deploymentKey: apiKey)) as? ExperimentPlugin)?.experiment
    }

    public var experiment: ExperimentClient? {
        let plugins = plugins(type: ExperimentPlugin.self)
        // If there's only one experiment instance attached, we can reference it directly
        if plugins.count == 1 {
            return plugins.first?.experiment
        } else {
            return nil
        }
    }
}
