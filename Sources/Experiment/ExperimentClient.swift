//
//  ExperimentClient.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public protocol ExperimentClient {
    func start(user: ExperimentUser, completion: (() -> Void)?) -> Void
    func setUser(user: ExperimentUser, completion: (() -> Void)?) -> Void
    func getUser() -> ExperimentUser?
    func getUserWithContext() -> ExperimentUser
    func getVariant(_ flagKey: String, fallback: Variant?) -> Variant?
    func getVariant(_ flagKey: String, fallback: String) -> Variant
    func getVariants() -> [String:Variant]
    func refetchAll(completion: (() -> Void)?) -> Void
    func setContextProvider(_ contextProvider: ContextProvider) -> ExperimentClient
}

public extension ExperimentClient {
    func getVariant(_ flagKey: String, fallback: Variant? = nil) -> Variant? {
        return getVariant(flagKey, fallback: fallback)
    }

    func getVariant(_ flagKey: String, fallback: String) -> Variant {
        return getVariant(flagKey, fallback: fallback)
    }
}

public class DefaultExperimentClient : ExperimentClient {

    internal let apiKey: String
    internal let storage: Storage
    internal let config: ExperimentConfig
    internal var userId: String?
    internal var user: ExperimentUser?
    internal var contextProvider: ContextProvider?

    init(apiKey: String, config: ExperimentConfig) {
        self.apiKey = apiKey
        self.storage = UserDefaultsStorage(apiKey: apiKey)
        self.config = config
        self.userId = nil
        self.user = nil
        self.contextProvider = nil
    }

    public func start(user: ExperimentUser, completion: (() -> Void)? = nil) -> Void {
        self.user = user
        self.loadFromStorage()
        self.fetchAll(completion: completion)
    }

    public func setUser(user: ExperimentUser, completion: (() -> Void)? = nil) -> Void {
        if self.user != user {
            self.user = user
            self.fetchAll(completion: completion)
        } else {
            completion?()
        }
    }

    public func getUser() -> ExperimentUser? {
        return self.user
    }

    public func getUserWithContext() -> ExperimentUser {
        let builder = ExperimentUser.Builder()
        if self.contextProvider != nil {
            if let deviceId = self.contextProvider?.getDeviceId(), deviceId != "" {
                _ = builder.setDeviceId(deviceId)
            }
            if let userId = self.contextProvider?.getUserId(), userId != "" {
                _ = builder.setUserId(userId)
            }
            _ = builder.setPlatform(self.contextProvider?.getPlatform())
                .setVersion(self.contextProvider?.getVersion())
                .setLanguage(self.contextProvider?.getLanguage())
                .setOs(self.contextProvider?.getOs())
                .setDeviceManufacturer(self.contextProvider?.getDeviceManufacturer())
                .setDeviceModel(self.contextProvider?.getDeviceModel())
        }
        return builder.setLibrary("\(ExperimentConfig.Constants.Library)/\(ExperimentConfig.Constants.Version)")
            .copyUser(self.user ?? ExperimentUser())
            .build()
    }

    public func refetchAll(completion: (() -> Void)? = nil) -> Void {
        self.fetchAll(completion:completion)
    }

    public func fetchAll(completion:  (() -> Void)? = nil) {
        let start = CFAbsoluteTimeGetCurrent()
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            let userContext = self.getUserWithContext()
            let userId = userContext.userId
            let deviceId = userContext.deviceId
            if userId == nil && deviceId == nil {
                print("[Experiment] WARN: user id and device id are null; amplitude will not be able to resolve identity")
            }
            let userContextDictionary = userContext.toDictionary()
            do {
                let requestData = try JSONSerialization.data(withJSONObject: userContextDictionary, options: [])
                let b64encodedUrl = requestData.base64EncodedString().replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "=", with: "")

                let url = URL(string: "\(self.config.serverUrl)/sdk/vardata/\(b64encodedUrl)")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
                let task = session.dataTask(with: request) { (data, response, error) in
                    // Check the response
                    if let httpResponse = response as? HTTPURLResponse {

                        // Check if an error occured
                        if (error != nil) {
                            // HERE you can manage the error
                            print("[Experiment] \(error!)")
                            completion?()
                            return
                        }

                        if (httpResponse.statusCode != 200) {
                            print("[Experiment] \(httpResponse.statusCode) received for \(url)")
                            completion?()
                            return
                        }

                        // Serialize the data into an object
                        do {
                            let flags = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: [String: Any]] ?? [:]
                            self.storage.clear()
                            for (key, value) in flags {
                                let variant = Variant(json: value)
                                if (variant != nil) {
                                    let _ = self.storage.put(key: key, value: variant!)
                                }
                            }
                            self.storage.save()
                            let end = CFAbsoluteTimeGetCurrent()
                            print("[Experiment] Fetched all: \(flags) for user \(userContext) in \(end - start)s")
                        } catch {
                            print("[Experiment] Error during JSON serialization: \(error.localizedDescription)")
                        }
                    }

                    completion?()
                }
                task.resume()
            } catch {
                print("[Experiment] Error during JSON serialization: \(error.localizedDescription)")
            }
        }
    }

    public func getVariant(_ flagKey: String, fallback: String) -> Variant {
        return self.storage.get(key: flagKey) ?? Variant(fallback, payload:nil)
    }

    public func getVariant(_ flagKey: String, fallback: Variant?) -> Variant? {
        return self.storage.get(key: flagKey) ?? fallback ?? self.config.initialFlags[flagKey] ?? self.config.fallbackVariant
    }

    public func getVariants() -> [String: Variant] {
        return self.storage.getAll()
    }

    public func setContextProvider(_ contextProvider: ContextProvider) -> ExperimentClient {
        self.contextProvider = contextProvider
        return self
    }

    func loadFromStorage() -> Void {
        self.storage.load()
        print("[Experiment] loaded \(self.storage.getAll())")
    }
}
