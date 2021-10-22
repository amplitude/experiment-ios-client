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
}
