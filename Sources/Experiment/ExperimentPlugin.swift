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

    @objcMembers
    public class Config : NSObject {

        public let debug: Bool
        public let fallbackVariant: Variant
        public let initialFlags: String?
        public let initialVariants: [String: Variant]
        public let source: Source
        public let serverUrl: String
        public let flagsServerUrl: String
        public let fetchTimeoutMillis: Int
        public let retryFetchOnFailure: Bool
        public let automaticExposureTracking: Bool
        public let fetchOnStart: NSNumber? // objc cant do nil boolean values, use nsnumber
        public let pollOnStart: Bool
        public let flagConfigPollingIntervalMillis: Int
        public let automaticFetchOnAmplitudeIdentityChange: Bool

        public init(debug: Bool = ExperimentConfig.Defaults.debug,
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

    private let config: Config
    private var analytics: (any AnalyticsClient)?
    private var logger: CoreLogger?

    public var name: String? {
        return Self.pluginName
    }

    @objc public init(config: Config = .init()) {
        self.config = config
    }

    public func setup(analyticsClient: any AmplitudeCore.AnalyticsClient,
                      amplitudeContext: AmplitudeCore.AmplitudeContext) {
        self.analytics = analyticsClient

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

        experiment = Experiment.initialize(apiKey: amplitudeContext.apiKey,
                                           config: configBuilder.build())
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

    public var experiment: ExperimentClient? {
        return (plugin(name: ExperimentPlugin.pluginName) as? ExperimentPlugin)?.experiment
    }
}
