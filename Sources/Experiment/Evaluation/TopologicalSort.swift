//
//  TopologicalSort.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal func topologicalSort(flags: [String: EvaluationFlag], flagKeys: [String]? = nil, sorted: Bool = false) throws -> [EvaluationFlag] {
    var available: [String: EvaluationFlag] = flags
    var result: [EvaluationFlag] = []
    // For testing, we want an consistent iteration order.
    let startingKeys: [String]
    if sorted {
        startingKeys = flagKeys ?? Array<String>(flags.keys.sorted())
    } else {
        startingKeys = flagKeys ?? Array<String>(flags.keys)
    }
    for flagKey in startingKeys {
        if let traversal = try parentTraversal(flagKey: flagKey, available: &available) {
            result.append(contentsOf: traversal)
        }
    }
    return result
}

private func parentTraversal(flagKey: String, available: inout [String: EvaluationFlag], path: [String] = []) throws -> [EvaluationFlag]? {
    var path = path
    guard let flag = available[flagKey] else {
        return nil
    }
    guard let flagDependencies = flag.dependencies, flagDependencies.count != 0 else {
        available.removeValue(forKey: flag.key)
        return [flag]
    }
    path.append(flag.key)
    var result: [EvaluationFlag] = []
    for parentKey in flagDependencies {
        if path.contains(parentKey) {
            throw CycleError("Detected a cycle between flags \(path)", path: path)
        }
        if let traversal = try parentTraversal(flagKey: parentKey, available: &available, path: path) {
            result.append(contentsOf: traversal)
        }
    }
    result.append(flag)
    available.removeValue(forKey: flag.key)
    return result
}

internal struct CycleError: Error {
    let path: [String]
    let message: String
    init(_ msg: String, path: [String]) {
        self.message = msg
        self.path = path
    }
}
