//
//  ExperimentConfig.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public enum Source {
    case LocalStorage
    case InitialVariants
}

public struct ExperimentConfig {

    public let debug: Bool
    public let fallbackVariant: Variant
    public let initialVariants: [String: Variant]
    public let source: Source
    public let serverUrl: String
    public let fetchTimeoutMillis: Int

    internal init(
        debug: Bool = ExperimentConfig.Defaults.debug,
        fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant,
        initialVariants: [String: Variant] = ExperimentConfig.Defaults.initialVariants,
        source: Source = ExperimentConfig.Defaults.source,
        serverUrl: String = ExperimentConfig.Defaults.serverUrl,
        fetchTimeoutMillis: Int = ExperimentConfig.Defaults.fetchTimeoutMillis
    ) {
        self.debug = debug
        self.fallbackVariant = fallbackVariant
        self.initialVariants = initialVariants
        self.source = source
        self.serverUrl = serverUrl
        self.fetchTimeoutMillis = fetchTimeoutMillis
    }

    internal struct Defaults {
        static let debug: Bool = false
        static let fallbackVariant: Variant = Variant()
        static let initialVariants: [String: Variant] = [:]
        static let source: Source = Source.LocalStorage
        static let serverUrl: String = "https://api.lab.amplitude.com"
        static let fetchTimeoutMillis: Int = 10000
    }
    
    public class Builder {
        
        private var debug: Bool = ExperimentConfig.Defaults.debug
        private var fallbackVariant: Variant = ExperimentConfig.Defaults.fallbackVariant
        private var initialVariants: [String: Variant] = ExperimentConfig.Defaults.initialVariants
        private var source: Source = ExperimentConfig.Defaults.source
        private var serverUrl: String = ExperimentConfig.Defaults.serverUrl
        
        public init() {
            // public init
        }
        
        public func debug(_ debug: Bool) -> Builder {
            self.debug = debug
            return self
        }
        
        public func fallbackVariant(_ fallbackVariant: Variant) -> Builder {
            self.fallbackVariant = fallbackVariant
            return self
        }
        
        public func initialVariants(_ initialVariants: [String: Variant]) -> Builder {
            self.initialVariants = initialVariants
            return self
        }
        
        public func source(_ source: Source) -> Builder {
            self.source = source
            return self
        }
        
        public func serverUrl(_ serverUrl: String) -> Builder {
            self.serverUrl = serverUrl
            return self
        }
        
        public func fetchTimeoutMillis(_ serverUrl: String) -> Builder {
            self.serverUrl = serverUrl
            return self
        }
        
        public func build() -> ExperimentConfig {
            return ExperimentConfig(
                debug: self.debug,
                fallbackVariant: self.fallbackVariant,
                initialVariants: self.initialVariants,
                serverUrl: self.serverUrl
            )
        }
    }

    internal struct Constants {
        // Version string is matched in release.config.js
        // Changing this may result in breaking automated releases
        internal static let Version: String = "0.1.0"
        internal static let Library: String = "experiment-ios-client"
    }
}
