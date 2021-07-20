//
//  ExperimentConfig.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public enum Source: Int {
    case LocalStorage = 0
    case InitialVariants = 1
}

@objc public class ExperimentConfig : NSObject {

    @objc public let debug: Bool
    @objc public let fallbackVariant: Variant
    @objc public let initialVariants: [String: Variant]
    @objc public let source: Source
    @objc public let serverUrl: String
    @objc public let fetchTimeoutMillis: Int
    @objc public let retryFetchOnFailure: Bool
    
    @objc public override init() {
        self.debug = ExperimentConfig.Defaults.debug
        self.fallbackVariant = ExperimentConfig.Defaults.fallbackVariant
        self.initialVariants = ExperimentConfig.Defaults.initialVariants
        self.source = ExperimentConfig.Defaults.source
        self.serverUrl = ExperimentConfig.Defaults.serverUrl
        self.fetchTimeoutMillis = ExperimentConfig.Defaults.fetchTimeoutMillis
        self.retryFetchOnFailure = ExperimentConfig.Defaults.retryFetchOnFailure
    }
    
    internal init(builder: ExperimentConfigBuilder) {
        self.debug = builder.debug
        self.fallbackVariant = builder.fallbackVariant
        self.initialVariants = builder.initialVariants
        self.source = builder.source
        self.serverUrl = builder.serverUrl
        self.fetchTimeoutMillis = builder.fetchTimeoutMillis
        self.retryFetchOnFailure = builder.retryFetchOnFailure
    }

    internal struct Defaults {
        static let debug: Bool = false
        static let fallbackVariant: Variant = Variant()
        static let initialVariants: [String: Variant] = [:]
        static let source: Source = Source.LocalStorage
        static let serverUrl: String = "https://api.lab.amplitude.com"
        static let fetchTimeoutMillis: Int = 10000
        static let retryFetchOnFailure: Bool = true
    }
    
    internal struct Constants {
        // Version string is matched in release.config.js
        // Changing this may result in breaking automated releases
        internal static let Version: String = "1.1.2"
        internal static let Library: String = "experiment-ios-client"
    }
}

@objc public class ExperimentConfigBuilder : NSObject {
    
    internal var debug: Bool = ExperimentConfig.Defaults.debug
    internal var fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant
    internal var initialVariants: [String: Variant] = ExperimentConfig.Defaults.initialVariants
    internal var source: Source = ExperimentConfig.Defaults.source
    internal var serverUrl: String = ExperimentConfig.Defaults.serverUrl
    internal var fetchTimeoutMillis: Int = ExperimentConfig.Defaults.fetchTimeoutMillis
    internal var retryFetchOnFailure: Bool = ExperimentConfig.Defaults.retryFetchOnFailure
    
    @objc public func debug(_ debug: Bool) -> ExperimentConfigBuilder {
        self.debug = debug
        return self
    }
    
    @objc public func fallbackVariant(_ fallbackVariant: Variant) -> ExperimentConfigBuilder {
        self.fallbackVariant = fallbackVariant
        return self
    }
    
    @objc public func initialVariants(_ initialVariants: [String: Variant]) -> ExperimentConfigBuilder {
        self.initialVariants = initialVariants
        return self
    }
    
    @objc public func source(_ source: Source) -> ExperimentConfigBuilder {
        self.source = source
        return self
    }
    
    @objc public func serverUrl(_ serverUrl: String) -> ExperimentConfigBuilder {
        self.serverUrl = serverUrl
        return self
    }
    
    @objc public func fetchTimeoutMillis(_ fetchTimeoutMillis: Int) -> ExperimentConfigBuilder {
        self.fetchTimeoutMillis = fetchTimeoutMillis
        return self
    }
    
    @objc public func fetchRetryOnFailure(_ fetchRetryOnFailure: Bool) -> ExperimentConfigBuilder {
        self.retryFetchOnFailure = fetchRetryOnFailure
        return self
    }

    @objc public func build() -> ExperimentConfig {
        return ExperimentConfig(builder: self)
    }
}

