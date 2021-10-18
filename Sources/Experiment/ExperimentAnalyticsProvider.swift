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

    /// Wraps an analytics event track call. This is typically called by the
    /// experiment client after setting user properties to track an
    /// "[Experiment] Exposure" event
    func track(_ event: ExperimentAnalyticsEvent)


    /// Wraps an analytics identify or set user property call. This is typically
    /// called by the experiment client before sending an
    /// "[Experiment] Exposure" event.
    func setUserProperty(_ event: ExperimentAnalyticsEvent)


    /// Wraps an analytics unset user property call. This is typically
    /// called by the experiment client when a user has been evaluated to use
    /// a fallback variant.
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent)
}
