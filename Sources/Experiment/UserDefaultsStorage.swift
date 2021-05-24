//
//  UserDefaultsStorage.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

class UserDefaultsStorage: Storage {
    let userDefaults = UserDefaults.standard
    let sharedPrefsKey: String
    let sharedPrefsPrefix = "com.amplitude.flags.cached."
    var map: [String:Variant] = [:]

    init(apiKey: String) {
        sharedPrefsKey = sharedPrefsPrefix + apiKey
    }

    func put(key: String, value: Variant) -> Variant? {
        let oldValue = self.get(key: key)
        map[key] = value
        return oldValue
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
            let data = userDefaults.value(forKey: self.sharedPrefsKey) as? Data,
            let loaded = try? JSONDecoder().decode([String:Variant].self, from: data) {
            for (key, value) in loaded {
                map[key] = value
            }
            return
        }

        if
            let loaded = userDefaults.dictionary(forKey: self.sharedPrefsKey) as? [String:String] {
            for (key, value) in loaded {
                map[key] = Variant(value)
            }
            return
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(map) {
            userDefaults.set(data, forKey: self.sharedPrefsKey)
        }
    }


}
