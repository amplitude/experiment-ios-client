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
public protocol ExperimentAnalyticsEvent {
    
    /// The name of the event. Should be passed as the event tracking name to the
    /// analytics implementation provided by the ``ExperimentAnalyticsProvider``.
    var name: String { get }
    
    /// Properties for the analytics event. Should be passed as the event
    /// properties to the analytics implementation provided by the
    /// ``ExperimentAnalyticsProvider``.
    var properties: [String: String?] { get }
}
