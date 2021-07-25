//
//  ExposureEvent.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

public class ExposureEvent : ExperimentAnalyticsEvent {
    
    public let name: String = "[Experiment] Exposure"
    public let properties: [String: String?]
    
    public let user: ExperimentUser
    public let key: String
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
