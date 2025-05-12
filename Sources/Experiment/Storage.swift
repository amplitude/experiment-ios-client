//
//  ExperimentStorage.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

internal func getVariantStorage(apiKey: String, instanceName: String, storage: Storage) -> LoadStoreCache<Variant> {
    let namespace = "com.amplituide.experiment.variants.\(instanceName).\(apiKey.suffix(6))"
    return LoadStoreCache(namespace: namespace, storage: storage)
}

internal func getFlagStorage(apiKey: String, instanceName: String, storage: Storage) -> LoadStoreCache<EvaluationFlag> {
    let namespace = "com.amplituide.experiment.flags.\(instanceName).\(apiKey.suffix(6))"
    return LoadStoreCache(namespace: namespace, storage: storage)
}

internal protocol Storage {
    func get(key: String) -> Data?
    func put(key: String, value: Data)
    func delete(key: String)
}

internal class UserDefaultsStorage: Storage {
    private let userDefaults = UserDefaults.standard
    
    func get(key: String) -> Data? {
        return userDefaults.value(forKey: key) as? Data
    }
    
    func put(key: String, value: Data) {
        userDefaults.set(value, forKey: key)
    }
    
    func delete(key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

private let storageQueue = DispatchQueue(label: "com.amplitude.experiment.loadStoreCache", attributes: .concurrent)

internal class LoadStoreCache<Value : Codable> {
    
    private var cache: [String: Value] = [:]
    private let namespace: String
    private let storage: Storage
    
    init(namespace: String, storage: Storage) {
        self.namespace = namespace
        self.storage = storage
    }
    
    func get(key: String) -> Value? {
        return cache[key]
    }
    
    func getAll() -> [String: Value] {
        return cache
    }
    
    func put(key: String, value: Value) {
        cache[key] = value
    }
    
    func putAll(values: [String: Value]) {
        for (k, v) in values {
            cache[k] = v
        }
    }
    
    func remove(key: String) {
        cache.removeValue(forKey: key)
    }
    
    func clear() {
        self.cache = [:]
    }
    
    func load() {
        do {
            if let data = storage.get(key: namespace) {
                self.cache = try JSONDecoder().decode([String: Value].self, from: data)
            } else {
                self.cache = [:]
            }
        } catch {
            print("[Experiment] load failed: \(error)")
        }
    }
    
    func store(async: Bool = true) {
        do {
            let data = try JSONEncoder().encode(cache)
            if (async) {
                storageQueue.async { [self] in
                    storage.put(key: self.namespace, value: data)
                }
            } else {
                // Used for testing
                storage.put(key: self.namespace, value: data)
            }
        } catch {
            print("[Experiment] save failed: \(error)")
        }
    }
}
