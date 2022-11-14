//
//  ExperimentStorage.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

internal protocol Storage {
    func put(key: String, value: Variant)
    func get(key: String) -> Variant?
    func clear()
    func remove(key: String)
    func getAll() -> [String:Variant]
    func load()
    func save()
}
