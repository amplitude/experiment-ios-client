//
//  ExperimentAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

/// Provides a analytics implementation for standard experiment events generated
/// by the client (e.g. ``ExposureEvent``).
public protocol ExperimentAnalyticsProvider {
    
    func track(_ event: ExperimentAnalyticsEvent)
}
