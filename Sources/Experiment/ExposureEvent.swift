//
//  ExposureEvent.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

/// Event for tracking a user's exposure to a variant. This event will not count
/// towards your analytics event volume.
@available(*, deprecated, message: "Use ExposureTrackingProvider instead.")
@objc public class ExposureEvent : NSObject, ExperimentAnalyticsEvent {

    @objc public let name: String = "[Experiment] Exposure"
    @objc public let properties: [String: String]
    @objc public let userProperties: [String : Any]?

    /// The user exposed to the flag/experiment variant.
    @objc public let user: ExperimentUser
    
    /// The key of the flag/experiment that the user has been exposed to.
    @objc public let key: String
    
    /// The variant of the flag/experiment that the user has been exposed to.
    @objc public let variant: Variant

    /// The user property key used to set user properties
    @objc public let userProperty: String
    
    @objc public init(user: ExperimentUser, key: String, variant: Variant, source: String) {
        self.user = user
        self.key = key
        self.variant = variant
        self.properties = [
            "key": key,
            "variant": variant.value ?? "null",
            "source": source
        ]
        self.userProperties = ["[Experiment] \(key)": variant.value ?? "null"]
        self.userProperty = "[Experiment] \(key)"
    }
}
