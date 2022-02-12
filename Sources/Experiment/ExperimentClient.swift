//
//  ExperimentClient.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public protocol ExperimentClient {
    @objc func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)?)
    @objc func variant(_ key: String) -> Variant
    @objc func variant(_ key: String, fallback: Variant?) -> Variant
    @objc func all() -> [String:Variant]
    @objc func exposure(key: String)
    @objc func setUser(_ user: ExperimentUser?)
    @objc func getUser() -> ExperimentUser?

    @available(*, deprecated, message: "User ExperimentConfig.userProvider instead")
    @objc func getUserProvider() -> ExperimentUserProvider?
    @available(*, deprecated, message: "User ExperimentConfig.userProvider instead")
    @objc func setUserProvider(_ userProvider: ExperimentUserProvider) -> ExperimentClient
}

private let fetchBackoffTimeout = 10000
private let fetchBackoffAttempts = 8
private let fetchBackoffMinMillis = 500
private let fetchBackoffMaxMillis = 10000
private let fetchBackoffScalar: Float = 1.5

internal class DefaultExperimentClient : NSObject, ExperimentClient {

    private let apiKey: String
    private let storage: Storage
    private let storageLock = DispatchSemaphore(value: 1)
    private let config: ExperimentConfig
    
    private var user: ExperimentUser? = nil
    private var userProvider: ExperimentUserProvider? = DefaultUserProvider()
    
    private var analyticsProvider: SessionAnalyticsProvider?
    private var exposureTrackingProvider: ExposureTrackingProvider?
    
    private var backoff: Backoff? = nil
    private let backoffLock = DispatchSemaphore(value: 1)
    
    private let fetchQueue = DispatchQueue(label: "com.amplitude.experiment.FetchQueue")

    internal init(apiKey: String, config: ExperimentConfig, storage: Storage) {
        self.apiKey = apiKey
        self.config = config
        if config.userProvider != nil {
            self.userProvider = config.userProvider
        }
        // Wrap the analytics provider in a session wrapper avoid unecessary exposure events.
        if let analyticsProvider = config.analyticsProvider {
            self.analyticsProvider = SessionAnalyticsProvider(analyticsProvider: analyticsProvider)
        } else {
            self.analyticsProvider = nil
        }
        if let exposureTrackingProvider = config.exposureTrackingProvider {
            self.exposureTrackingProvider = SessionExposureTrackingProvider(exposureTrackingProvider: exposureTrackingProvider)
        } else {
            self.exposureTrackingProvider = nil
        }
        self.storage = storage
        self.storage.load()
    }

    public func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)? = nil) -> Void {
        if user != nil && user != ExperimentUser() {
            self.user = user
        }
        fetchQueue.async {
            do {
                let fetchUser = try self.mergeUserWithProviderOrWait(timeout: .seconds(1))
                _ = self.fetchInternal(
                    user: fetchUser,
                    timeoutMillis: self.config.fetchTimeoutMillis,
                    retry: self.config.retryFetchOnFailure
                ) { result in
                    switch result {
                    case .success:
                        completion?(self, nil)
                    case .failure(let error):
                        completion?(self, error)
                    }
                }
            } catch {
                completion?(self, error)
            }
        }
    }
    
    public func variant(_ key: String) -> Variant {
        return variant(key, fallback: nil)
    }
    
    public func variant(_ key: String, fallback: Variant?) -> Variant {
        let variantAndSource = resolveVariantAndSource(key: key, fallback: fallback)
        let variant = variantAndSource.variant;
        let source = variantAndSource.source;
        if (config.automaticExposureTracking) {
            exposureInternal(key: key, variant: variant, source: source)
        }
        return variant
    }

    public func all() -> [String: Variant] {
        return sourceVariants().merging(secondaryVariants()) { (source, _) in source }
    }

    public func exposure(key: String) {
        let variantAndSource = resolveVariantAndSource(key: key, fallback: nil)
        exposureInternal(key: key, variant: variantAndSource.variant, source: variantAndSource.source)
    }

    public func getUser() -> ExperimentUser? {
        return self.user
    }

    public func setUser(_ user: ExperimentUser?) {
        self.user = user
    }

    @available(*, deprecated, message: "User ExperimentConfig.userProvider instead")
    public func getUserProvider() -> ExperimentUserProvider? {
        return self.userProvider
    }

    @available(*, deprecated, message: "User ExperimentConfig.userProvider instead")
    public func setUserProvider(_ userProvider: ExperimentUserProvider) -> ExperimentClient {
        self.userProvider = userProvider
        return self
    }

    private func resolveVariantAndSource(key: String, fallback: Variant?) -> VariantAndSource {
        if (config.source == Source.InitialVariants) {
            // for source = InitialVariants, fallback order goes:
            // 1. InitialFlags
            // 2. Local Storage
            // 3. Function fallback
            // 4. Config fallback

            let sourceVariant = sourceVariants()[key];
            if let variant = sourceVariant {
                return VariantAndSource(variant: variant, source: VariantSource.InitialVariants)
            }
            let secondaryVariant = secondaryVariants()[key]
            if let variant = secondaryVariant {
                return VariantAndSource(variant: variant, source: VariantSource.SecondaryLocalStorage)
            }
            if let variant = fallback {
                return VariantAndSource(variant: variant, source: VariantSource.FallbackInline)
            }
            return VariantAndSource(variant: config.fallbackVariant, source: VariantSource.FallbackConfig)
        } else {
            // for source = LocalStorage, fallback order goes:
            // 1. Local Storage
            // 2. Function fallback
            // 3. InitialFlags
            // 4. Config fallback

            let sourceVariant = sourceVariants()[key];
            if let variant = sourceVariant {
                return VariantAndSource(variant: variant, source: VariantSource.LocalStorage)
            }
            if let variant = fallback {
                return VariantAndSource(variant: variant, source: VariantSource.FallbackInline)
            }
            let secondaryVariant = secondaryVariants()[key]
            if let variant = secondaryVariant {
                return VariantAndSource(variant: variant, source: VariantSource.SecondaryInitialVariants)
            }
            return VariantAndSource(variant: config.fallbackVariant, source: VariantSource.FallbackConfig)
        }
    }

    public func fetchInternal(
        user: ExperimentUser,
        timeoutMillis: Int,
        retry: Bool,
        completion: @escaping ((Result<[String: Variant], Error>) -> Void)
    ) -> URLSessionTask? {
        // Proactively cancel retries if active in order to avoid unecessary API
        // requests. A new failure will restart the retries.
        if retry {
            self.stopRetries()
        }
        return self.doFetch(user: user, timeoutMillis: timeoutMillis) { result in
            switch result {
            case .success(let variants):
                self.storeVariants(variants)
                completion(result)
            case .failure:
                completion(result)
                if retry {
                    self.startRetries(user: user)
                }
            }
        }
    }

    // Must be run on fetchQueue
    public func doFetch(
        user: ExperimentUser,
        timeoutMillis: Int,
        completion: @escaping ((Result<[String: Variant], Error>) -> Void)
    ) -> URLSessionTask? {
        let start = CFAbsoluteTimeGetCurrent()
        
        let userId = user.userId
        let deviceId = user.deviceId
        if userId == nil && deviceId == nil {
            print("[Experiment] WARN: user id and device id are null; amplitude will not be able to resolve identity")
        }
        self.debug("Fetch variants for user: \(user)")
        // Build fetch request
        let userDictionary = user.toDictionary()
        guard let requestData = try? JSONSerialization.data(withJSONObject: userDictionary, options: []) else {
            completion(Result.failure(ExperimentError("json encode failed from dictionary: \(userDictionary)")))
            return nil
        }
        let userB64EncodedUrl = requestData.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        let url = URL(string: "\(self.config.serverUrl)/sdk/vardata")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(userB64EncodedUrl, forHTTPHeaderField: "X-Amp-Exp-User")
        request.timeoutInterval = Double(timeoutMillis) / 1000.0
        
        // Do fetch request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(Result.failure(ExperimentError("Response is nil")))
                return
            }
            self.debug("Received fetch response: \(httpResponse)")
            guard httpResponse.statusCode == 200 else {
                completion(Result.failure(ExperimentError("Error Response: status=\(httpResponse.statusCode)")))
                return
            }
            do {
                let variants = try self.parseResponseData(data)
                let end = CFAbsoluteTimeGetCurrent()
                self.debug("Fetched variants in \(end - start) s")
                completion(Result.success(variants))
            } catch {
                print("[Experiment] Failed to parse response data: \(error)")
                completion(Result.failure(error))
            }
        }
        task.resume()
        return task
    }

    private func startRetries(user: ExperimentUser) {
        backoffLock.wait()
        defer { backoffLock.signal() }
        self.backoff?.cancel()
        self.backoff = Backoff(
            attempts: fetchBackoffAttempts,
            min: fetchBackoffMinMillis,
            max: fetchBackoffMaxMillis,
            scalar: fetchBackoffScalar
        )
        self.backoff?.start() { completion in
            return self.fetchInternal(user: user, timeoutMillis: fetchBackoffTimeout, retry: false) { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    private func stopRetries() {
        backoffLock.wait()
        defer { backoffLock.signal() }
        self.backoff?.cancel()
        self.backoff = nil
    }

    internal func mergeUserWithProvider() -> ExperimentUser {
        var libraryUser: ExperimentUser = self.user ?? ExperimentUser()
        if self.user?.library == nil {
            let library = "\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)"
            libraryUser = libraryUser.copyToBuilder().library(library).build()
        }
        return libraryUser.merge(userProvider?.getUser())
    }
    
    internal func mergeUserWithProviderOrWait(timeout: DispatchTimeInterval) throws -> ExperimentUser {
        var providedUser: ExperimentUser?
        if let connectorUserProvider = self.userProvider as? ConnectorUserProvider {
            providedUser = try connectorUserProvider.getUserOrWait(timeout: timeout)
        } else {
            providedUser = self.userProvider?.getUser()
        }
        var libraryUser: ExperimentUser = self.user ?? ExperimentUser()
        if self.user?.library == nil {
            let library = "\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)"
            libraryUser = libraryUser.copyToBuilder().library(library).build()
        }
        return libraryUser.merge(providedUser)
    }

    private func parseResponseData(_ data: Data?) throws -> [String: Variant] {
        guard let data = data else {
            throw ExperimentError("Response data is nil")
        }
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let keys = jsonObject as? [String: [String: Any]] else {
            throw ExperimentError("Failed to cast response json to [String: [String: Any]]")
        }
        var variants = [String: Variant]()
        for (key, value) in keys {
            if let variant = Variant(json: value) {
                variants[key] = variant
            }
        }
        return variants
    }
    
    private func storeVariants(_ variants: [String: Variant]) {
        storageLock.wait()
        defer { storageLock.signal() }
        storage.clear()
        for (key, variant) in variants {
            self.storage.put(key: key, value: variant)
        }
        storage.save()
        self.debug("Stored variants: \(variants)")
    }
    
    private func sourceVariants() -> [String: Variant] {
        switch config.source {
        case .LocalStorage:
            storageLock.wait()
            defer { storageLock.signal() }
            return storage.getAll()
        case .InitialVariants:
            return config.initialVariants
        }
    }
    
    private func secondaryVariants() -> [String: Variant] {
        switch config.source {
        case .LocalStorage:
            return config.initialVariants
        case .InitialVariants:
            storageLock.wait()
            defer { storageLock.signal() }
            return storage.getAll()
        }
    }
    
    private func exposureInternal(key: String, variant: Variant, source: VariantSource) {
        let exposedUser = mergeUserWithProvider()
        let event = ExposureEvent(user: exposedUser, key: key, variant: variant, source: source.rawValue)
        // Track the exposure event if an analytics provider is set
        if (source.isFallback() || variant.value == nil) {
            self.exposureTrackingProvider?.track(exposure: Exposure(flagKey: key, variant: nil))
            self.analyticsProvider?.unsetUserProperty(event)
        } else if (variant.value != nil) {
            self.exposureTrackingProvider?.track(exposure: Exposure(flagKey: key, variant: variant.value))
            self.analyticsProvider?.setUserProperty(event)
            self.analyticsProvider?.track(event)
        }
    }

    private func debug(_ msg: String) {
        if self.config.debug {
            print("[Experiment] \(msg)")
        }
    }
}

private struct VariantAndSource {
    public private(set) var variant: Variant
    public private(set) var source: VariantSource
}

private enum VariantSource : String {
    case LocalStorage = "storage"
    case InitialVariants = "initial"
    case SecondaryLocalStorage = "secondary-storage"
    case SecondaryInitialVariants = "secondary-initial"
    case FallbackInline = "fallback-inline"
    case FallbackConfig = "fallback-config"

    func isFallback() -> Bool {
        switch self {
        case .FallbackInline, .FallbackConfig:
            return true
        default:
            return false
        }
    }
}
