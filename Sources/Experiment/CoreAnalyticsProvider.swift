//
//  CoreAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AmplitudeCore

internal class CoreAnalyticsProvider : ExperimentAnalyticsProvider {
    
    private let analyticsConnector: AnalyticsConnector
    private var setProperties: [String: String] = [:]
    private var unsetProperties: [String: String] = [:]
    
    internal init(analyticsConnector: AnalyticsConnector) {
        self.analyticsConnector = analyticsConnector
    }
    
    func track(_ event: ExperimentAnalyticsEvent) {
        guard let variant = event.variant.value else {
            return
        }
        if setProperties[event.key] == variant {
            return
        } else {
            setProperties[event.key] = variant
            unsetProperties.removeValue(forKey: event.key)
        }
        let analyticsEvent = AnalyticsEvent(
            eventType: event.name,
            eventProperties: NSDictionary(dictionary: event.properties),
            userProperties: nil
        )
        analyticsConnector.logEvent(event: analyticsEvent)
    }
    
    func setUserProperty(_ event: ExperimentAnalyticsEvent) {
        guard let variant = event.variant.value else {
            return
        }
        if setProperties[event.key] == variant {
            return
        }
        let analyticsEvent = AnalyticsEvent(
            eventType: "$identify",
            eventProperties: nil,
            userProperties: NSDictionary(dictionary: ["$set": [event.userProperty: variant]])
        )
        analyticsConnector.logEvent(event: analyticsEvent)
    }
    
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        if unsetProperties[event.key] != nil {
            return
        } else {
            unsetProperties[event.key] = "-"
            setProperties.removeValue(forKey: event.key)
        }
        let analyticsEvent = AnalyticsEvent(
            eventType: "$identify",
            eventProperties: nil,
            userProperties: NSDictionary(dictionary: ["$unset": [event.userProperty: "-"]])
        )
        analyticsConnector.logEvent(event: analyticsEvent)
    }
}
