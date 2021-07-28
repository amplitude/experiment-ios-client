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
    
    /// The user exposed to the flag/experiment variant.
    public let user: ExperimentUser
    
    /// The key of the flag/experiment that the user has been exposed to.
    public let key: String
    
    /// The variant of the flag/experiment that the user has been exposed to.
    public let variant: Variant
    
    public init(user: ExperimentUser, key: String, variant: Variant) {
        self.user = user
        self.key = key
        self.variant = variant
        self.properties = [
            "key": key,
            "variant": variant.value
        ]
    }
}
