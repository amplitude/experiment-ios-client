//
//  UserDefaultsStorage.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

internal class UserDefaultsStorage: Storage {
    let userDefaults = UserDefaults.standard
    let key: String
    var map: [String:Variant] = [:]

    init(instanceName: String, apiKey: String) {
        key = "com.amplituide.experiment.variants.\(instanceName).\(apiKey.suffix(6))"
    }

    func put(key: String, value: Variant) {
        map[key] = value
    }

    func get(key: String) -> Variant? {
        return map[key]
    }

    func clear() {
        map = [:]
    }

    func getAll() -> [String:Variant] {
        let copy = map
        return copy
    }

    func load() {
        if
            let data = userDefaults.value(forKey: self.key) as? Data,
            let loaded = try? JSONDecoder().decode([String:Variant].self, from: data) {
            for (key, value) in loaded {
                map[key] = value
            }
            return
        }

        if
            let loaded = userDefaults.dictionary(forKey: self.key) as? [String:String] {
            for (key, value) in loaded {
                map[key] = Variant(value)
            }
            return
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(map) {
            userDefaults.set(data, forKey: self.key)
        }
    }


}
