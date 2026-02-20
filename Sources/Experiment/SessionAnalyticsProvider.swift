//
//  SessionAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/11/22.
//

import Foundation

/// Wraps another analytics provider in order to limit exposure events to once per flag,
/// per session unless the variant changes. Effectively minimizes the number of exposure
/// events sent per user.
internal class SessionAnalyticsProvider : NSObject, ExperimentAnalyticsProvider, @unchecked Sendable {
    // @unchecked Sendable:
    // let analyticsProvider is Sendable.
    // All properties changes are guarded.

    private let analyticsProvider: ExperimentAnalyticsProvider
    private var setProperties: [String: String] = [:]
    private var unsetProperties: [String: String] = [:]
    private let propertiesLock = DispatchSemaphore(value: 1)
    
    init(analyticsProvider: ExperimentAnalyticsProvider) {
        self.analyticsProvider = analyticsProvider
    }
    
    func track(_ event: ExperimentAnalyticsEvent) {
        guard let variant = event.variant.value else {
            return
        }
        do {
            propertiesLock.wait()
            defer { propertiesLock.signal() }
            if setProperties[event.key] == variant {
                return
            } else {
                setProperties[event.key] = variant
                unsetProperties.removeValue(forKey: event.key)
            }
        }
        analyticsProvider.track(event)
    }
    
    func setUserProperty(_ event: ExperimentAnalyticsEvent) {
        guard let variant = event.variant.value else {
            return
        }
        do {
            propertiesLock.wait()
            defer { propertiesLock.signal() }
            if setProperties[event.key] == variant {
                return
            }
        }
        analyticsProvider.setUserProperty(event)
    }
    
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        do {
            propertiesLock.wait()
            defer { propertiesLock.signal() }
            if unsetProperties[event.key] != nil {
                return
            } else {
                unsetProperties[event.key] = "-"
                setProperties.removeValue(forKey: event.key)
            }
        }
        analyticsProvider.unsetUserProperty(event)
    }
}
