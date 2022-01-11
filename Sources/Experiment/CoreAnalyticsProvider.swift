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
    
    internal init(analyticsConnector: AnalyticsConnector) {
        self.analyticsConnector = analyticsConnector
    }
    
    func track(_ event: ExperimentAnalyticsEvent) {
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
        let analyticsEvent = AnalyticsEvent(
            eventType: "$identify",
            eventProperties: nil,
            userProperties: NSDictionary(dictionary: ["$set": [event.userProperty: variant]])
        )
        analyticsConnector.logEvent(event: analyticsEvent)
    }
    
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        let analyticsEvent = AnalyticsEvent(
            eventType: "$identify",
            eventProperties: nil,
            userProperties: NSDictionary(dictionary: ["$unset": [event.userProperty: "-"]])
        )
        analyticsConnector.logEvent(event: analyticsEvent)
    }
}
