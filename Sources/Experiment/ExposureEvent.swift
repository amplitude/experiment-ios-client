//
//  ExposureEvent.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

/// Event for tracking a user's exposure to a variant. This event will not count
/// towards your analytics event volume.
public class ExposureEvent : ExperimentAnalyticsEvent {    
    public let name: String = "[Experiment] Exposure"
    public let properties: [String: String?]
    public let userProperties: [String : Any?]?

    public let user: ExperimentUser
    public let key: String
    public let variant: Variant
    public let userProperty: String

    
    public init(user: ExperimentUser, key: String, variant: Variant, source: String) {
        self.user = user
        self.key = key
        self.variant = variant
        self.properties = [
            "key": key,
            "variant": variant.value,
            "source": source
        ]
        self.userProperties = ["[Experiment] \(key)": variant.value]
        self.userProperty = "[Experiment] \(key)"
    }
}
