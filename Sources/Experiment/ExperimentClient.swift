//
//  ExperimentClient.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public protocol ExperimentClient {
    func fetch(user: ExperimentUser, completion: ((ExperimentClient, Error?) -> Void)?)
    func variant(_ key: String) -> Variant
    func variant(_ key: String, fallback: Variant?) -> Variant
    func all() -> [String:Variant]
    func setUser(_ user: ExperimentUser?)
    func getUser() -> ExperimentUser?
    func getUserProvider() -> ExperimentUserProvider?
    func setUserProvider(_ userProvider: ExperimentUserProvider) -> ExperimentClient
}

public class DefaultExperimentClient : ExperimentClient {

    private let apiKey: String
    private let storage: Storage
    private let storageLock = DispatchSemaphore(value: 1)
    private let config: ExperimentConfig
    
    private var user: ExperimentUser? = nil
    private var userProvider: ExperimentUserProvider? = DefaultUserProvider()

    internal init(apiKey: String, config: ExperimentConfig, storage: Storage) {
        self.apiKey = apiKey
        self.config = config
        self.storage = storage
        self.storage.load()
    }

    public func fetch(user: ExperimentUser, completion: ((ExperimentClient, Error?) -> Void)? = nil) -> Void {
        self.user = user
        let fetchUser = self.mergeUserWithProvider()
        self.doFetch(user: fetchUser) { result in
            switch result {
            case .success(let variants):
                self.storeVariants(variants)
                completion?(self, nil)
            case .failure(let error):
                completion?(self, error)
            }
        }
    }
    
    public func variant(_ key: String) -> Variant {
        return self.all()[key] ?? self.config.fallbackVariant
    }
    
    public func variant(_ key: String, fallback: Variant?) -> Variant {
        return sourceVariants()[key] ??
            fallback ??
            secondaryVariants()[key] ??
            self.config.fallbackVariant
    }

    public func all() -> [String: Variant] {
        return sourceVariants().merging(secondaryVariants()) { (source, _) in source }
    }

    public func getUser() -> ExperimentUser? {
        return self.user
    }
    
    public func setUser(_ user: ExperimentUser?) {
        self.user = user
    }
    
    public func getUserProvider() -> ExperimentUserProvider? {
        return self.userProvider
    }
    
    public func setUserProvider(_ userProvider: ExperimentUserProvider) -> ExperimentClient {
        self.userProvider = userProvider
        return self
    }

    public func doFetch(
        user: ExperimentUser,
        completion: @escaping ((Result<[String: Variant], Error>) -> Void)
    ) {
        let start = CFAbsoluteTimeGetCurrent()
        
        let userId = user.userId
        let deviceId = user.deviceId
        if userId == nil && deviceId == nil {
            print("[Experiment] WARN: user id and device id are null; amplitude will not be able to resolve identity")
        }
        
        // Build fetch request
        let userDictionary = user.toDictionary()
        guard let requestData = try? JSONSerialization.data(withJSONObject: userDictionary, options: []) else {
            completion(Result.failure(ExperimentError("json encode failed from dictionary: \(userDictionary)")))
            return
        }
        let b64encodedUrl = requestData.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        let url = URL(string: "\(self.config.serverUrl)/sdk/vardata/\(b64encodedUrl)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = Double(config.fetchTimeoutMillis) / 1000.0
        
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
            guard httpResponse.statusCode == 200 else {
                completion(Result.failure(ExperimentError("Error Response: status=\(httpResponse.statusCode)")))
                return
            }
            do {
                let variants = try self.parseResponseData(data)
                let end = CFAbsoluteTimeGetCurrent()
                print("[Experiment] Fetched variants in \(end - start) s")
                completion(Result.success(variants))
            } catch {
                print("[Experiment] Failed to parse response data: \(error)")
                completion(Result.failure(error))
            }
        }
        task.resume()
    }

    internal func mergeUserWithProvider() -> ExperimentUser {
        var libraryUser: ExperimentUser = self.user ?? ExperimentUser()
        if self.user?.library == nil {
            let library = "\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)"
            libraryUser = libraryUser.copyToBuilder().library(library).build()
        }
        return libraryUser.merge(userProvider?.getUser())
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
    }
    
    private func sourceVariants() -> [String: Variant] {
        switch config.source {
        case .LocalStorage:
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
            return storage.getAll()
        }
    }
}
