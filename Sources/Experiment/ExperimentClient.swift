//
//  ExperimentClient.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public protocol ExperimentClient {
    @objc func start(_ user: ExperimentUser?, completion: ((Error?) -> Void)?) -> Void
    @objc func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)?)
    @objc func fetch(user: ExperimentUser?, options: FetchOptions?, completion: ((ExperimentClient, Error?) -> Void)?)
    @objc func variant(_ key: String) -> Variant
    @objc func variant(_ key: String, fallback: Variant?) -> Variant
    @objc func all() -> [String:Variant]
    @objc func exposure(key: String)
    @objc func setUser(_ user: ExperimentUser?)
    @objc func getUser() -> ExperimentUser?
    @objc func clear()

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

private let euServerUrl = "https://api.lab.eu.amplitude.com";
private let euFlagsServerUrl = "https://flag.lab.eu.amplitude.com";

internal class DefaultExperimentClient : NSObject, ExperimentClient {

    private let apiKey: String
    
    internal let variants: LoadStoreCache<Variant>
    private let variantsStorageQueue = DispatchQueue(label: "com.amplitude.experiment.VariantsStorageQueue", attributes: .concurrent)
    
    internal let flags: LoadStoreCache<EvaluationFlag>
    private let flagsStorageQueue = DispatchQueue(label: "com.amplitude.experiment.VariantsStorageQueue", attributes: .concurrent)

    internal let config: ExperimentConfig
    private let engine = EvaluationEngine()
    
    private var isRunning = false
    private let runningLock = DispatchSemaphore(value: 1)
    private var poller: DispatchSourceTimer? = nil
    private var pollerQueue = DispatchQueue(label: "com.amplitude.experiment.PollerQueue", qos: .background)
    
    private var user: ExperimentUser? = nil
    private var userProvider: ExperimentUserProvider? = DefaultUserProvider()
    
    private var analyticsProvider: SessionAnalyticsProvider?
    private var userSessionExposureTracker: UserSessionExposureTracker?
    
    private var backoff: Backoff? = nil
    private let backoffLock = DispatchSemaphore(value: 1)
    
    private let fetchQueue = DispatchQueue(label: "com.amplitude.experiment.FetchQueue")
    private let flagsQueue = DispatchQueue(label: "com.amplitude.experiment.FlagsQueue")
    private let startQueue = DispatchQueue(label: "com.amplitude.experiment.StartQueue")

    internal init(apiKey: String, config: ExperimentConfig, storage: Storage) {
        self.apiKey = apiKey
        let configBuilder = config.copyToBuilder()
        if config.serverUrl == ExperimentConfig.Defaults.serverUrl && config.flagsServerUrl == ExperimentConfig.Defaults.flagsServerUrl && config.serverZone == .EU {
            configBuilder.serverUrl(euServerUrl).flagsServerUrl(euFlagsServerUrl)
        }
        self.config = configBuilder.build()
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
            self.userSessionExposureTracker = UserSessionExposureTracker(exposureTrackingProvider: exposureTrackingProvider)
        } else {
            self.userSessionExposureTracker = nil
        }
        self.variants = getVariantStorage(apiKey: self.apiKey, instanceName: self.config.instanceName, storage: storage)
        self.variants.load()
        self.flags = getFlagStorage(apiKey: self.apiKey, instanceName: self.config.instanceName, storage: storage)
        self.flags.load()
    }
    
    public func start(_ user: ExperimentUser? = nil, completion: ((Error?) -> Void)? = nil) -> Void {
        runningLock.wait()
        if isRunning {
            runningLock.signal()
            return
        }
        isRunning = true
        if self.config.pollOnStart {
            let timer = DispatchSource.makeTimerSource(queue: pollerQueue)
            timer.schedule(deadline: .now() + .seconds(60), repeating: .seconds(60))
            timer.setEventHandler { self.flagsInternal() }
            timer.activate()
            self.poller = timer
        }
        runningLock.signal()
        setUser(user)
        // Determine to fetch remove evaluation variants on start, either using the configured setting, or dynamically by checking the flag cache.
        var remoteFlags = config.fetchOnStart?.boolValue ?? flagsStorageQueue.sync { self.flags.getAll() }.contains { (_, flag: EvaluationFlag) in
            flag.isRemoteEvaluationMode()
        }
        startQueue.async {
            var error: Error? = nil
            if (remoteFlags) {
                // We already have remote flags in our flag cache, so we know we need to
                // evaluate remotely even before we've updated our flags.
                let startGroup = DispatchGroup()
                startGroup.enter()
                startGroup.enter()
                self.flagsInternal { e in
                    if let e = e {
                        error = e
                    }
                    startGroup.leave()
                }
                self.fetch(user: user) { _, e in
                    if let e = e {
                        error = e
                    }
                    startGroup.leave()
                }
                startGroup.wait()
            } else {
                // We don't know if remote evaluation is required, await the flag promise,
                // and recheck for remote flags.
                let flagsGroup = DispatchGroup()
                flagsGroup.enter()
                self.flagsInternal { e in
                    if let e = e {
                        error = e
                    }
                    flagsGroup.leave()
                }
                flagsGroup.wait()
                remoteFlags = self.config.fetchOnStart?.boolValue ?? self.flagsStorageQueue.sync { self.flags.getAll() }.contains { (_, flag: EvaluationFlag) in
                    flag.isRemoteEvaluationMode()
                }
                if (remoteFlags) {
                    let fetchGroup = DispatchGroup()
                    fetchGroup.enter()
                    self.fetch(user: user) { _, e in
                        if let e = e {
                            error = e
                        }
                        fetchGroup.leave()
                    }
                    fetchGroup.wait()
                }
            }
            completion?(error)
        }
    }
    
    public func stop() {
        self.runningLock.wait()
        if isRunning {
            isRunning = false
            poller?.cancel()
            self.poller = nil
        }
        self.runningLock.signal()
    }

    public func fetch(user: ExperimentUser?, completion: ((ExperimentClient, Error?) -> Void)? = nil) -> Void {
        self.fetch(user: user, options: nil, completion: completion)
    }

    public func fetch(user: ExperimentUser?, options: FetchOptions?, completion: ((ExperimentClient, Error?) -> Void)? = nil) -> Void {
        if user != nil && user != ExperimentUser() {
            self.user = user
        }
        fetchQueue.async {
            do {
                let fetchUser = try self.mergeUserWithProviderOrWait(timeout: .seconds(10))
                _ = self.fetchInternal(
                    user: fetchUser,
                    timeoutMillis: self.config.fetchTimeoutMillis,
                    retry: self.config.retryFetchOnFailure,
                    options: options
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
        let variantAndSource = variantAndSource(key: key, fallback: fallback)
        if (config.automaticExposureTracking) {
            exposureInternal(key: key, variantAndSource: variantAndSource)
        }
        return variantAndSource.variant
    }

    public func all() -> [String: Variant] {
        var localVariants = evaluate()
        for flagKey in localVariants.keys {
            if let flag = flagsStorageQueue.sync(execute: { flags.get(key: flagKey) }), !flag.isLocalEvaluationMode() {
                localVariants.removeValue(forKey: flagKey)
            }
        }
        let remoteAndSecondaryVariants = sourceVariants().merging(secondaryVariants()) { (source, _) in source }
        return localVariants.merging(remoteAndSecondaryVariants) { (local, _) in local }
    }

    // Clear all variants in the cache and storage.
    public func clear() {
        variantsStorageQueue.sync(flags: .barrier) {
            self.variants.clear();
            self.variants.store();
        }
    }

    public func exposure(key: String) {
        let variantAndSource = variantAndSource(key: key, fallback: nil)
        exposureInternal(key: key, variantAndSource: variantAndSource)
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
    
    private func evaluate(flagKeys: [String] = []) -> [String: Variant] {
        var keys: [String]? = nil
        if !flagKeys.isEmpty {
            keys = flagKeys
        }
        let user = mergeUserWithProvider()
        do {
            let storageFlags = flagsStorageQueue.sync { self.flags.getAll() }
            let flags = try topologicalSort(flags: storageFlags, flagKeys: keys)
            let evaluationVariants = engine.evaluate(context: user.toEvaluationContext(), flags: flags)
            return evaluationVariants.mapValues { evaluationVariant in
                evaluationVariant.toVariant()
            }
        } catch {
            print("[Experiment] encountered evaluation error: \(error)")
            return [:]
        }
    }
    
    /**
     * For Source.LocalStorage, fallback order goes:
     *
     *  1. Local Storage
     *  2. Inline function fallback
     *  3. InitialFlags
     *  4. Config fallback
     *
     * If there is a default variant and no fallback, return the default variant.
     */
    private func localStorageVariantAndSource(key: String, fallback: Variant?) -> VariantAndSource {
        var defaultVariantAndSource: VariantAndSource = VariantAndSource()
        // Local storage
        let localStorageVariant = variantsStorageQueue.sync { variants.get(key: key) }
        let isLocalStorageDefault = localStorageVariant?.isDefaultVariant() ?? false
        if let localStorageVariant = localStorageVariant, !isLocalStorageDefault {
            return VariantAndSource(variant: localStorageVariant, source: .LocalStorage, hasDefaultVariant: false)
        } else if (isLocalStorageDefault) {
            defaultVariantAndSource = VariantAndSource(variant: localStorageVariant ?? Variant(), source: .LocalStorage, hasDefaultVariant: true)
        }
        // Inline fallback
        if let fallback = fallback {
            return VariantAndSource(variant: fallback, source: .FallbackInline, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Initial variants
        if let initialVariant = config.initialVariants[key] {
            return VariantAndSource(variant: initialVariant, source: .SecondaryInitialVariants, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Configured fallback, or default variant
        if !config.fallbackVariant.isEmpty() {
            return VariantAndSource(variant: config.fallbackVariant, source: .FallbackConfig, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        return defaultVariantAndSource
    }
    
    /**
     * For Source.InitialVariants, fallback order goes:
     *
     *  1. Initial variants
     *  2. Local storage
     *  3. Inline function fallback
     *  4. Config fallback
     *
     * If there is a default variant and no fallback, return the default variant.
     */
    private func initialVariantsVariantAndSource(key: String, fallback: Variant?) -> VariantAndSource {
        var defaultVariantAndSource: VariantAndSource = VariantAndSource()
        // Initial variants
        if let initialVariant = config.initialVariants[key] {
            return VariantAndSource(variant: initialVariant, source: .InitialVariants, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Local storage
        let localStorageVariant = variantsStorageQueue.sync { variants.get(key: key) }
        let isLocalStorageDefault = localStorageVariant?.isDefaultVariant() ?? false
        if let localStorageVariant = localStorageVariant, !isLocalStorageDefault {
            return VariantAndSource(variant: localStorageVariant, source: .LocalStorage, hasDefaultVariant: false)
        } else if (isLocalStorageDefault) {
            defaultVariantAndSource = VariantAndSource(variant: localStorageVariant ?? Variant(), source: .LocalStorage, hasDefaultVariant: true)
        }
        // Inline fallback
        if let fallback = fallback {
            return VariantAndSource(variant: fallback, source: .FallbackInline, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Configured fallback, or default variant
        if !config.fallbackVariant.isEmpty() {
            return VariantAndSource(variant: config.fallbackVariant, source: .FallbackConfig, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        return defaultVariantAndSource
    }
    
    /**
     * This function assumes the flag exists and is local evaluation mode. For
     * local evaluation, fallback order goes:
     *
     *  1. Local evaluation
     *  2. Inline function fallback
     *  3. Initial variants
     *  4. Config fallback
     *
     * If there is a default variant and no fallback, return the default variant.
     */
    private func localEvalautionVariantAndSource(key: String, flag: EvaluationFlag, fallback: Variant?) -> VariantAndSource {
        var defaultVariantAndSource: VariantAndSource = VariantAndSource()
        // Local evaluation
        let variant = self.evaluate(flagKeys: [flag.key])[key]
        let source = VariantSource.LocalEvaluation
        let isLocalEvaluationDefault = variant?.isDefaultVariant() ?? false
        if let variant = variant, !isLocalEvaluationDefault {
            return VariantAndSource(variant: variant, source: source, hasDefaultVariant: false)
        } else if isLocalEvaluationDefault {
            defaultVariantAndSource = VariantAndSource(variant: variant ?? Variant(), source: source, hasDefaultVariant: true)
        }
        // Inline fallback
        if let fallback = fallback {
            return VariantAndSource(variant: fallback, source: .FallbackInline, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Initial variants
        if let initialVariant = config.initialVariants[key] {
            return VariantAndSource(variant: initialVariant, source: .SecondaryInitialVariants, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        // Configured fallback, or default variant
        if !config.fallbackVariant.isEmpty() {
            return VariantAndSource(variant: config.fallbackVariant, source: .FallbackConfig, hasDefaultVariant: defaultVariantAndSource.hasDefaultVariant)
        }
        return defaultVariantAndSource
    }
    
    private func variantAndSource(key: String, fallback: Variant?) -> VariantAndSource {
        var variantAndSource: VariantAndSource = VariantAndSource()
        switch config.source {
        case .LocalStorage:
            variantAndSource = localStorageVariantAndSource(key: key, fallback: fallback)
        case .InitialVariants:
            variantAndSource = initialVariantsVariantAndSource(key: key, fallback: fallback)
        }
        guard let flag = flagsStorageQueue.sync(execute: { flags.get(key: key) }) else {
            return variantAndSource
        }
        if flag.isLocalEvaluationMode() || (variantAndSource.variant.isEmpty()) {
            variantAndSource = localEvalautionVariantAndSource(key: key, flag: flag, fallback: fallback)
        }
        return variantAndSource
    }

    public func fetchInternal(
        user: ExperimentUser,
        timeoutMillis: Int,
        retry: Bool,
        options: FetchOptions?,
        completion: @escaping ((Result<[String: Variant], Error>) -> Void)
    ) -> URLSessionTask? {
        // Proactively cancel retries if active in order to avoid unecessary API
        // requests. A new failure will restart the retries.
        if retry {
            self.stopRetries()
        }
        return self.doFetch(user: user, timeoutMillis: timeoutMillis, options: options) { result in
            switch result {
            case .success(let variants):
                self.storeVariants(variants, options)
                completion(result)
            case .failure:
                completion(result)
                if retry {
                    self.startRetries(user: user, options: options)
                }
            }
        }
    }
    
    private func flagsInternal(completion: ((Error?) -> Void)? = nil) {
        flagsQueue.async {
            self.debug("Updating flag configurations")
            return self.doFlags(timeoutMillis: self.config.fetchTimeoutMillis) { result in
                switch result {
                case .success(let flags):
                    self.debug("Got \(flags.count) flag configurations")
                    self.flagsStorageQueue.sync(flags: .barrier) {
                        self.flags.clear()
                        self.flags.putAll(values: flags)
                        self.flags.store()
                    }
                    completion?(nil)
                case .failure(let error):
                    print("[Expeirment] get flags failed: \(error)")
                    completion?(error)
                }
            }
        }
    }
    
    // Must be run on flagsQueue
    internal func doFlags(
        timeoutMillis: Int,
        completion: @escaping ((Result<[String: EvaluationFlag], Error>) -> Void)
    ) {
        let url = URL(string: "\(config.flagsServerUrl)/sdk/v2/flags")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = Double(timeoutMillis) / 1000.0
        // Do fetch request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(Result.failure(ExperimentError("Response is nil")))
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(Result.failure(ExperimentError("Error Response: status=\(httpResponse.statusCode)")))
                return
            }
            guard let data = data else {
                completion(Result.failure(ExperimentError("Flag response data is nil")))
                return
            }
            do {
                let flags = try JSONDecoder().decode([EvaluationFlag].self, from: data)
                var result: [String: EvaluationFlag] = [:]
                for flag in flags {
                    result[flag.key] = flag
                }
                completion(Result.success(result))
            } catch {
                print("[Experiment] Failed to parse flag data: \(error)")
                completion(Result.failure(error))
            }
        }.resume()
    }

    // Must be run on fetchQueue
    internal func doFetch(
        user: ExperimentUser,
        timeoutMillis: Int,
        options: FetchOptions?,
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
        let userB64EncodedUrl = base64EncodeData(requestData)
        let url = URL(string: "\(self.config.serverUrl)/sdk/v2/vardata?v=0")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(userB64EncodedUrl, forHTTPHeaderField: "X-Amp-Exp-User")
        if let flagKeys = options?.flagKeys {
            guard let jsonFlagKeys = try? JSONSerialization.data(withJSONObject: flagKeys, options: []) else {
                completion(Result.failure(ExperimentError("json encode failed from flag keys: \(String(describing: flagKeys))")))
                return nil
            }
            let flagKeysB64EncodedUrl = base64EncodeData(jsonFlagKeys)
            request.setValue(flagKeysB64EncodedUrl, forHTTPHeaderField: "X-Amp-Exp-Flag-Keys")
        }
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
            guard let data = data else {
                completion(Result.failure(ExperimentError("Response data is nil")))
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

    private func startRetries(user: ExperimentUser, options: FetchOptions?) {
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
            return self.fetchInternal(user: user, timeoutMillis: fetchBackoffTimeout, retry: false, options: options) { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    private func base64EncodeData(_ key: Data) -> String {
        return key.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
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
        return try JSONDecoder().decode([String: Variant].self, from: data)
    }
    
    private func storeVariants(_ variants: [String: Variant], _ options: FetchOptions?) {
        variantsStorageQueue.sync(flags: .barrier) {
            if (options?.flagKeys == nil) {
                self.variants.clear()
            }
            var failedKeys: [String] = options?.flagKeys ?? []
            for (key, variant) in variants {
                failedKeys.removeAll { $0 == key }
                self.variants.put(key: key, value: variant)
            }
            for (key) in failedKeys {
                self.variants.remove(key: key)
            }
            self.variants.store()
            self.debug("Stored variants: \(variants)")
        }
    }
    
    private func sourceVariants() -> [String: Variant] {
        switch config.source {
        case .LocalStorage:
            return variantsStorageQueue.sync { variants.getAll() }
        case .InitialVariants:
            return config.initialVariants
        }
    }
    
    private func secondaryVariants() -> [String: Variant] {
        switch config.source {
        case .LocalStorage:
            return config.initialVariants
        case .InitialVariants:
            return variantsStorageQueue.sync { variants.getAll() }
        }
    }
    
    private func exposureInternal(key: String, variantAndSource: VariantAndSource) {
        legacyExposureInternal(key: key, variantAndSource: variantAndSource)
        guard let userSessionExposureTracker = self.userSessionExposureTracker else {
            return
        }
        // Do not track exposure for fallback variants that are not associated with
        // a default variant.
        let fallback = variantAndSource.source?.isFallback() ?? true
        let hasDefaultVariant = variantAndSource.hasDefaultVariant
        if fallback && !hasDefaultVariant {
            return
        }
        var exposureVariant: String? = nil
        if !fallback && !variantAndSource.variant.isDefaultVariant() {
            exposureVariant = variantAndSource.variant.key ?? variantAndSource.variant.value
        }
        userSessionExposureTracker.track(exposure: Exposure(flagKey: key, variant: exposureVariant, experimentKey: variantAndSource.variant.expKey, metadata: variantAndSource.variant.metadata))
    }
    
    private func legacyExposureInternal(key: String, variantAndSource: VariantAndSource) {
        guard let analyticsProvider = analyticsProvider else {
            return
        }
        let variant = variantAndSource.variant
        let source = variantAndSource.source
        let exposedUser = mergeUserWithProvider()
        let event = ExposureEvent(user: exposedUser, key: key, variant: variantAndSource.variant, source: variantAndSource.source?.rawValue ?? "unknown")
        // Track the exposure event if an analytics provider is set
        if (source?.isFallback() ?? true || variant.value == nil) {
            analyticsProvider.unsetUserProperty(event)
        } else if (variant.value != nil) {
            analyticsProvider.setUserProperty(event)
            analyticsProvider.track(event)
        }
    }

    private func debug(_ msg: String) {
        if self.config.debug {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            print("\(formatter.string(from: Date())) [Experiment] \(msg)")
        }
    }
}

private struct VariantAndSource {
    var variant: Variant
    var source: VariantSource?
    var hasDefaultVariant: Bool
    
    init(variant: Variant = Variant(), source: VariantSource? = nil, hasDefaultVariant: Bool = false) {
        self.variant = variant
        self.source = source
        self.hasDefaultVariant = hasDefaultVariant
    }
}

private enum VariantSource : String {
    case LocalStorage = "storage"
    case InitialVariants = "initial"
    case SecondaryLocalStorage = "secondary-storage"
    case SecondaryInitialVariants = "secondary-initial"
    case FallbackInline = "fallback-inline"
    case FallbackConfig = "fallback-config"
    case LocalEvaluation = "local-evaluation"

    func isFallback() -> Bool {
        switch self {
        case .FallbackInline, .FallbackConfig, .SecondaryInitialVariants:
            return true
        default:
            return false
        }
    }
}

internal extension EvaluationVariant {
    func toVariant() -> Variant {
        var metadata: [String: Any]? = nil
        if let m = self.metadata {
            metadata = m as [String: Any]
        }
        let experimentKey = self.metadata?["experimentKey"] as? String ?? nil
        return Variant(self.value as? String, payload: self.payload, expKey: experimentKey, key: self.key, metadata: metadata)
    }
}
