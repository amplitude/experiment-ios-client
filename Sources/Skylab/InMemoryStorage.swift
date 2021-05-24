//
//  InMemoryStorage.swift
//  Skylab
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

class InMemoryStorage: Storage {
    var map: [String:Variant] = [:]

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
    
    func load() {}
    func save() {}
    
    
}
