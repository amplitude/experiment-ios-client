//
//  Selectable.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal protocol Selectable {
    func select(selector: String) -> Any?
}

extension NSDictionary: Selectable {
    func select(selector: String) -> Any? {
        return self[selector]
    }
}

extension Dictionary: Selectable where Key == String {
    func select(selector: String) -> Any? {
        return self[selector] ?? nil
    }
}

internal extension Selectable {
    func select(selector: [String?]?) -> Any? {
        guard let selector = selector else {
            return nil
        }
        guard !selector.isEmpty else {
            return nil
        }
        var selectable: Selectable = self
        for i in 0..<selector.count-1 {
            guard let selectorElement = selector[i] else {
                return nil
            }
            let value = selectable.select(selector: selectorElement)
            guard let value = value as? Selectable else {
                return nil
            }
            selectable = value
        }
        guard let lastSelector = selector[selector.count - 1] else {
            return nil
        }
        return selectable.select(selector: lastSelector)
    }
}
