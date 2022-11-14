//
//  InMemoryStorage.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

internal class InMemoryStorage: Storage {
    
    var map: [String:Variant] = [:]

    func put(key: String, value: Variant) {
        map[key] = value
    }

    func get(key: String) -> Variant? {
        return map[key]
    }

    func clear() {
        map = [:]
    }
    
    func remove(key: String) {
        map.removeValue(forKey: key)
    }

    func getAll() -> [String:Variant] {
        let copy = map
        return copy
    }
    
    func load() {}
    func save() {}
}
