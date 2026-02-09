//
//  ExperimentConfig.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public enum Source: Int, Sendable {
    case LocalStorage = 0
    case InitialVariants = 1
}

@objc public enum ServerZone: Int, Sendable {
    case US = 0
    case EU = 1
}

/// - Note: Uses @unchecked Sendable due to @objc compatibility requirements
///   and protocol type erasure. All properties are immutable (`let`).
@objc public final class ExperimentConfig : NSObject, Sendable {

    @objc public let debug: Bool
    @objc public let instanceName: String
    @objc public let fallbackVariant: Variant
    @objc public let initialFlags: String?
    @objc public let initialVariants: [String: Variant]
    @objc public let source: Source
    @objc public let serverUrl: String
    @objc public let flagsServerUrl: String
    @objc public let serverZone: ServerZone
    @objc public let fetchTimeoutMillis: Int
    @objc public let retryFetchOnFailure: Bool
    @objc public let automaticExposureTracking: Bool
    @objc public let fetchOnStart: NSNumber? // objc cant do nil boolean values, use nsnumber
    @objc public let pollOnStart: Bool
    @objc public let flagConfigPollingIntervalMillis: Int
    @objc public let automaticFetchOnAmplitudeIdentityChange: Bool
    @objc public let userProvider: ExperimentUserProvider?
    @available(*, deprecated, message: "Use exposureTrackingProvider instead.")
    @objc public let analyticsProvider: ExperimentAnalyticsProvider?
    @objc public let exposureTrackingProvider: ExposureTrackingProvider?
    @objc public let customRequestHeaders: CustomRequestHeadersBuilder
    
    @objc public override init() {
        self.debug = ExperimentConfig.Defaults.debug
        self.instanceName = ExperimentConfig.Defaults.instanceName
        self.fallbackVariant = ExperimentConfig.Defaults.fallbackVariant
        self.initialFlags = ExperimentConfig.Defaults.initialFlags
        self.initialVariants = ExperimentConfig.Defaults.initialVariants
        self.source = ExperimentConfig.Defaults.source
        self.serverUrl = ExperimentConfig.Defaults.serverUrl
        self.flagsServerUrl = ExperimentConfig.Defaults.flagsServerUrl
        self.serverZone = ExperimentConfig.Defaults.serverZone
        self.fetchTimeoutMillis = ExperimentConfig.Defaults.fetchTimeoutMillis
        self.retryFetchOnFailure = ExperimentConfig.Defaults.retryFetchOnFailure
        self.automaticExposureTracking = ExperimentConfig.Defaults.automaticExposureTracking
        self.fetchOnStart = ExperimentConfig.Defaults.fetchOnStart
        self.pollOnStart = ExperimentConfig.Defaults.pollOnStart
        self.flagConfigPollingIntervalMillis = ExperimentConfig.Defaults.flagConfigPollingIntervalMillis
        self.automaticFetchOnAmplitudeIdentityChange = ExperimentConfig.Defaults.automaticFetchOnAmplitudeIdentityChange
        self.userProvider = ExperimentConfig.Defaults.userProvider
        self.analyticsProvider = ExperimentConfig.Defaults.analyticsProvider
        self.exposureTrackingProvider = ExperimentConfig.Defaults.exposureTrackingProvider
        self.customRequestHeaders = ExperimentConfig.Defaults.customRequestHeaders
    }
    
    internal init(builder: ExperimentConfigBuilder) {
        self.debug = builder.debug
        self.instanceName = builder.instanceName
        self.fallbackVariant = builder.fallbackVariant
        self.initialFlags = builder.initialFlags
        self.initialVariants = builder.initialVariants
        self.source = builder.source
        self.serverUrl = builder.serverUrl
        self.flagsServerUrl = builder.flagsServerUrl
        self.serverZone = builder.serverZone
        self.fetchTimeoutMillis = builder.fetchTimeoutMillis
        self.retryFetchOnFailure = builder.retryFetchOnFailure
        self.automaticExposureTracking = builder.automaticExposureTracking
        self.fetchOnStart = builder.fetchOnStart
        self.pollOnStart = builder.pollOnStart
        self.flagConfigPollingIntervalMillis = builder.flagConfigPollingIntervalMillis
        self.automaticFetchOnAmplitudeIdentityChange = builder.automaticFetchOnAmplitudeIdentityChange
        self.userProvider = builder.userProvider
        self.analyticsProvider = builder.analyticsProvider
        self.exposureTrackingProvider = builder.exposureTrackingProvider
        self.customRequestHeaders = builder.customRequestHeaders
    }
    
    internal init(builder: ExperimentConfig.Builder) {
        self.debug = builder.debug
        self.instanceName = builder.instanceName
        self.fallbackVariant = builder.fallbackVariant
        self.initialFlags = builder.initialFlags
        self.initialVariants = builder.initialVariants
        self.source = builder.source
        self.serverUrl = builder.serverUrl
        self.flagsServerUrl = builder.flagsServerUrl
        self.serverZone = builder.serverZone
        self.fetchTimeoutMillis = builder.fetchTimeoutMillis
        self.retryFetchOnFailure = builder.retryFetchOnFailure
        self.automaticExposureTracking = builder.automaticExposureTracking
        self.fetchOnStart = builder.fetchOnStart
        self.pollOnStart = builder.pollOnStart
        self.flagConfigPollingIntervalMillis = builder.flagConfigPollingIntervalMillis
        self.automaticFetchOnAmplitudeIdentityChange = builder.automaticFetchOnAmplitudeIdentityChange
        self.userProvider = builder.userProvider
        self.analyticsProvider = builder.analyticsProvider
        self.exposureTrackingProvider = builder.exposureTrackingProvider
        self.customRequestHeaders = builder.customRequestHeaders
    }

    public struct Defaults {
        public static let debug: Bool = false
        public static let instanceName: String = "$default_instance"
        public static let fallbackVariant: Variant = Variant()
        public static let initialFlags: String? = nil
        public static let initialVariants: [String: Variant] = [:]
        public static let source: Source = Source.LocalStorage
        public static let serverUrl: String = "https://api.lab.amplitude.com"
        public static let flagsServerUrl: String = "https://flag.lab.amplitude.com"
        public static let serverZone: ServerZone = .US
        public static let fetchTimeoutMillis: Int = 10000
        public static let retryFetchOnFailure: Bool = true
        public static let automaticExposureTracking: Bool = true
        public static let fetchOnStart: NSNumber? = 1
        public static let pollOnStart: Bool = true
        public static let flagConfigPollingIntervalMillis = 300000
        public static let automaticFetchOnAmplitudeIdentityChange: Bool = false
        public static let userProvider: ExperimentUserProvider? = nil
        public static let analyticsProvider: ExperimentAnalyticsProvider? = nil
        public static let exposureTrackingProvider: ExposureTrackingProvider? = nil
        public static let customRequestHeaders: CustomRequestHeadersBuilder = { [:] }
    }
    
    public typealias CustomRequestHeadersBuilder = @Sendable () -> [String: String]
    
    @available(*, deprecated, message: "Use ExperimentConfigBuilder instead")
    public class Builder {
            
        internal var debug: Bool = ExperimentConfig.Defaults.debug
        internal var instanceName = ExperimentConfig.Defaults.instanceName
        internal var fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant
        internal var initialFlags: String? = ExperimentConfig.Defaults.initialFlags
        internal var initialVariants: [String: Variant] = ExperimentConfig.Defaults.initialVariants
        internal var source: Source = ExperimentConfig.Defaults.source
        internal var serverUrl: String = ExperimentConfig.Defaults.serverUrl
        internal var flagsServerUrl: String = ExperimentConfig.Defaults.flagsServerUrl
        internal var serverZone: ServerZone = ExperimentConfig.Defaults.serverZone
        internal var fetchTimeoutMillis: Int = ExperimentConfig.Defaults.fetchTimeoutMillis
        internal var retryFetchOnFailure: Bool = ExperimentConfig.Defaults.retryFetchOnFailure
        internal var automaticExposureTracking: Bool = ExperimentConfig.Defaults.automaticExposureTracking
        internal var fetchOnStart: NSNumber? = ExperimentConfig.Defaults.fetchOnStart
        internal var pollOnStart: Bool = true
        internal var flagConfigPollingIntervalMillis = ExperimentConfig.Defaults.flagConfigPollingIntervalMillis
        internal var automaticFetchOnAmplitudeIdentityChange: Bool = ExperimentConfig.Defaults.automaticFetchOnAmplitudeIdentityChange
        internal var userProvider: ExperimentUserProvider? = ExperimentConfig.Defaults.userProvider
        internal var analyticsProvider: ExperimentAnalyticsProvider? = ExperimentConfig.Defaults.analyticsProvider
        internal var exposureTrackingProvider: ExposureTrackingProvider? = ExperimentConfig.Defaults.exposureTrackingProvider
        internal var customRequestHeaders: CustomRequestHeadersBuilder = ExperimentConfig.Defaults.customRequestHeaders
        
        public init() {
            // public init
        }
        
        @discardableResult
        public func debug(_ debug: Bool) -> Builder {
            self.debug = debug
            return self
        }
        
        @discardableResult
        public func instanceName(_ instanceName: String) -> Builder {
            self.instanceName = instanceName
            return self
        }
        
        @discardableResult
        public func fallbackVariant(_ fallbackVariant: Variant) -> Builder {
            self.fallbackVariant = fallbackVariant
            return self
        }
        
        @discardableResult
        public func initialFlags(_ initialFlags: String?) -> Builder {
            self.initialFlags = initialFlags
            return self
        }
        
        @discardableResult
        public func initialVariants(_ initialVariants: [String: Variant]) -> Builder {
            self.initialVariants = initialVariants
            return self
        }
        
        @discardableResult
        public func source(_ source: Source) -> Builder {
            self.source = source
            return self
        }
        
        @discardableResult
        public func serverUrl(_ serverUrl: String) -> Builder {
            self.serverUrl = serverUrl
            return self
        }
        
        @discardableResult
        public func flagsServerUrl(_ flagsServerUrl: String) -> Builder {
            self.flagsServerUrl = flagsServerUrl
            return self
        }
        
        @discardableResult
        public func serverZone(_ serverZone: ServerZone) -> Builder {
            self.serverZone = serverZone
            return self
        }
        
        @discardableResult
        public func fetchTimeoutMillis(_ fetchTimeoutMillis: Int) -> Builder {
            self.fetchTimeoutMillis = fetchTimeoutMillis
            return self
        }
        
        @discardableResult
        public func fetchRetryOnFailure(_ fetchRetryOnFailure: Bool) -> Builder {
            self.retryFetchOnFailure = fetchRetryOnFailure
            return self
        }
        
        @discardableResult
        public func automaticExposureTracking(_ automaticExposureTracking: Bool) -> Builder {
            self.automaticExposureTracking = automaticExposureTracking
            return self
        }
        
        
        @discardableResult
        public func fetchOnStart(_ fetchOnStart: Bool) -> Builder {
            if fetchOnStart {
                self.fetchOnStart = 1
            } else {
                self.fetchOnStart = 0
            }
            return self
        }
        
        @discardableResult
        public func pollOnStart(_ pollOnStart: Bool) -> Builder {
            self.pollOnStart = pollOnStart
            return self
        }
        
        @discardableResult
        public func flagConfigPollingIntervalMillis(_ flagConfigPollingIntervalMillis: Int) -> Builder {
            self.flagConfigPollingIntervalMillis = flagConfigPollingIntervalMillis
            return self
        }
        
        @discardableResult
        public func automaticFetchOnAmplitudeIdentityChange(_ automaticFetchOnAmplitudeIdentityChange: Bool) -> Builder {
            self.automaticFetchOnAmplitudeIdentityChange = automaticFetchOnAmplitudeIdentityChange
            return self
        }
        
        @discardableResult
        public func userProvider(_ userProvider: ExperimentUserProvider?) -> Builder {
            self.userProvider = userProvider
            return self
        }
        
        @discardableResult
        public func analyticsProvider(_ analyticsProvider: ExperimentAnalyticsProvider?) -> Builder {
            self.analyticsProvider = analyticsProvider
            return self
        }
        
        @discardableResult
        public func exposureTrackingProvider(_ exposureTrackingProvider: ExposureTrackingProvider?) -> Builder {
            self.exposureTrackingProvider = exposureTrackingProvider
            return self
        }
        
        @discardableResult
        public func customRequestHeaders(_ customRequestHeaders: @escaping ExperimentConfig.CustomRequestHeadersBuilder) -> Builder {
            self.customRequestHeaders = customRequestHeaders
            return self
        }

        public func build() -> ExperimentConfig {
            return ExperimentConfig(builder: self)
        }
    }
    
    internal struct Constants {
        // Version string is matched in release.config.js
        // Changing this may result in breaking automated releases
        internal static let Version: String = "1.18.3"
        internal static let Library: String = "experiment-ios-client"
    }
    
    internal func copyToBuilder() -> ExperimentConfigBuilder {
        let fetchOnStart = self.fetchOnStart?.boolValue
        let builder = ExperimentConfigBuilder()
            .debug(self.debug)
            .instanceName(self.instanceName)
            .fallbackVariant(self.fallbackVariant)
            .initialFlags(self.initialFlags)
            .initialVariants(self.initialVariants)
            .source(self.source)
            .serverUrl(self.serverUrl)
            .flagsServerUrl(self.flagsServerUrl)
            .serverZone(self.serverZone)
            .fetchTimeoutMillis(self.fetchTimeoutMillis)
            .fetchRetryOnFailure(self.retryFetchOnFailure)
            .automaticExposureTracking(self.automaticExposureTracking)
            .pollOnStart(self.pollOnStart)
            .flagConfigPollingIntervalMillis(self.flagConfigPollingIntervalMillis)
            .automaticFetchOnAmplitudeIdentityChange(self.automaticFetchOnAmplitudeIdentityChange)
            .userProvider(self.userProvider)
            .analyticsProvider(self.analyticsProvider)
            .exposureTrackingProvider(self.exposureTrackingProvider)
            .customRequestHeaders(self.customRequestHeaders)
        if let fetchOnStart = fetchOnStart {
            builder.fetchOnStart(fetchOnStart)
        }
        return builder
    }
}

@objc public class ExperimentConfigBuilder : NSObject {
    
    internal var debug: Bool = ExperimentConfig.Defaults.debug
    internal var instanceName: String = ExperimentConfig.Defaults.instanceName
    internal var fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant
    internal var initialFlags: String? = ExperimentConfig.Defaults.initialFlags
    internal var initialVariants: [String: Variant] = ExperimentConfig.Defaults.initialVariants
    internal var source: Source = ExperimentConfig.Defaults.source
    internal var serverUrl: String = ExperimentConfig.Defaults.serverUrl
    internal var flagsServerUrl: String = ExperimentConfig.Defaults.flagsServerUrl
    internal var serverZone: ServerZone = ExperimentConfig.Defaults.serverZone
    internal var fetchTimeoutMillis: Int = ExperimentConfig.Defaults.fetchTimeoutMillis
    internal var retryFetchOnFailure: Bool = ExperimentConfig.Defaults.retryFetchOnFailure
    internal var automaticExposureTracking: Bool = ExperimentConfig.Defaults.automaticExposureTracking
    internal var fetchOnStart: NSNumber? = ExperimentConfig.Defaults.fetchOnStart
    internal var pollOnStart: Bool = true
    internal var flagConfigPollingIntervalMillis: Int = ExperimentConfig.Defaults.flagConfigPollingIntervalMillis
    internal var automaticFetchOnAmplitudeIdentityChange: Bool = ExperimentConfig.Defaults.automaticFetchOnAmplitudeIdentityChange
    internal var userProvider: ExperimentUserProvider? = ExperimentConfig.Defaults.userProvider
    internal var analyticsProvider: ExperimentAnalyticsProvider? = ExperimentConfig.Defaults.analyticsProvider
    internal var exposureTrackingProvider: ExposureTrackingProvider? = ExperimentConfig.Defaults.exposureTrackingProvider
    internal var customRequestHeaders: ExperimentConfig.CustomRequestHeadersBuilder = ExperimentConfig.Defaults.customRequestHeaders
    
    @discardableResult
    @objc public func debug(_ debug: Bool) -> ExperimentConfigBuilder {
        self.debug = debug
        return self
    }
    
    @discardableResult
    @objc public func instanceName(_ instanceName: String) -> ExperimentConfigBuilder {
        self.instanceName = instanceName
        return self
    }
    
    @discardableResult
    @objc public func fallbackVariant(_ fallbackVariant: Variant) -> ExperimentConfigBuilder {
        self.fallbackVariant = fallbackVariant
        return self
    }
    
    @discardableResult
    @objc public func initialFlags(_ initialFlags: String?) -> ExperimentConfigBuilder {
        self.initialFlags = initialFlags
        return self
    }
    
    @discardableResult
    @objc public func initialVariants(_ initialVariants: [String: Variant]) -> ExperimentConfigBuilder {
        self.initialVariants = initialVariants
        return self
    }
    
    @discardableResult
    @objc public func source(_ source: Source) -> ExperimentConfigBuilder {
        self.source = source
        return self
    }
    
    @discardableResult
    @objc public func serverUrl(_ serverUrl: String) -> ExperimentConfigBuilder {
        self.serverUrl = serverUrl
        return self
    }
    
    @discardableResult
    @objc public func flagsServerUrl(_ flagsServerUrl: String) -> ExperimentConfigBuilder {
        self.flagsServerUrl = flagsServerUrl
        return self
    }
    
    @discardableResult
    @objc public func serverZone(_ serverZone: ServerZone) -> ExperimentConfigBuilder {
        self.serverZone = serverZone
        return self
    }
    
    @discardableResult
    @objc public func fetchTimeoutMillis(_ fetchTimeoutMillis: Int) -> ExperimentConfigBuilder {
        self.fetchTimeoutMillis = fetchTimeoutMillis
        return self
    }
    
    @discardableResult
    @objc public func fetchRetryOnFailure(_ fetchRetryOnFailure: Bool) -> ExperimentConfigBuilder {
        self.retryFetchOnFailure = fetchRetryOnFailure
        return self
    }
    
    @discardableResult
    @objc public func automaticExposureTracking(_ automaticExposureTracking: Bool) -> ExperimentConfigBuilder {
        self.automaticExposureTracking = automaticExposureTracking
        return self
    }
    
    @discardableResult
    @objc public func fetchOnStart(_ fetchOnStart: Bool) -> ExperimentConfigBuilder {
        if fetchOnStart {
            self.fetchOnStart = 1
        } else {
            self.fetchOnStart = 0
        }
        return self
    }
    
    @discardableResult
    @objc public func pollOnStart(_ pollOnStart: Bool) -> ExperimentConfigBuilder {
        self.pollOnStart = pollOnStart
        return self
    }
    
    @discardableResult
    @objc public func flagConfigPollingIntervalMillis(_ flagConfigPollingIntervalMillis: Int) -> ExperimentConfigBuilder {
        self.flagConfigPollingIntervalMillis = flagConfigPollingIntervalMillis
        return self
    }
    
    @discardableResult
    @objc public func automaticFetchOnAmplitudeIdentityChange(_ automaticFetchOnAmplitudeIdentityChange: Bool) -> ExperimentConfigBuilder {
        self.automaticFetchOnAmplitudeIdentityChange = automaticFetchOnAmplitudeIdentityChange
        return self
    }

    @discardableResult
    @objc public func userProvider(_ userProvider: ExperimentUserProvider?) -> ExperimentConfigBuilder {
        self.userProvider = userProvider
        return self
    }
    
    @discardableResult
    @objc public func analyticsProvider(_ analyticsProvider: ExperimentAnalyticsProvider?) -> ExperimentConfigBuilder {
        self.analyticsProvider = analyticsProvider
        return self
    }
    
    @discardableResult
    @objc public func exposureTrackingProvider(_ exposureTrackingProvider: ExposureTrackingProvider?) -> ExperimentConfigBuilder {
        self.exposureTrackingProvider = exposureTrackingProvider
        return self
    }
    
    @discardableResult
    @objc public func customRequestHeaders(_ customRequestHeaders: @escaping ExperimentConfig.CustomRequestHeadersBuilder) -> ExperimentConfigBuilder {
        self.customRequestHeaders = customRequestHeaders
        return self
    }
    
    @objc public func build() -> ExperimentConfig {
        return ExperimentConfig(builder: self)
    }
}

