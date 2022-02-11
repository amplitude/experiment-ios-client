//
//  ExperimentAnalyticsEvent.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

/// Analytics event for tracking events generated from the experiment SDK client.
/// These events are sent to the implementation provided by an
/// ``ExperimentAnalyticsProvider``.
@available(*, deprecated, message: "Use ExposureTrackingProvider instead.")
@objc public protocol ExperimentAnalyticsEvent {
    
    /// The name of the event. Should be passed as the event tracking name to the
    /// analytics implementation provided by the ``ExperimentAnalyticsProvider``.
    @objc var name: String { get }
    
    /// Properties for the analytics event. Should be passed as the event
    /// properties to the analytics implementation provided by the
    /// ``ExperimentAnalyticsProvider``.
    @objc var properties: [String: String] { get }
    
    /// User properties to identify with the user prior to sending the event.
    @objc var userProperties: [String: Any]? { get }

    /// The user exposed to the flag/experiment variant.
    @objc var user: ExperimentUser { get };

    /// The key of the flag/experiment that the user has been exposed to.
    @objc var key: String { get };

    /// The variant of the flag/experiment that the user has been exposed to.
    @objc var variant: Variant { get };

    /// The user property for the flag/experiment (auto-generated from the key)
    @objc var userProperty: String { get };
}
