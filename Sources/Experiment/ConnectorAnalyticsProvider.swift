//
//  ConnectorAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AnalyticsConnector

internal class ConnectorAnalyticsProvider : ExperimentAnalyticsProvider {
    
    private let eventBridge: EventBridge
    
    internal init(eventBridge: EventBridge) {
        self.eventBridge = eventBridge
    }
    
    func track(_ event: ExperimentAnalyticsEvent) {
        let analyticsEvent = AnalyticsEvent(
            eventType: event.name,
            eventProperties: NSDictionary(dictionary: event.properties),
            userProperties: nil
        )
        eventBridge.logEvent(event: analyticsEvent)
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
        eventBridge.logEvent(event: analyticsEvent)
    }
    
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        let analyticsEvent = AnalyticsEvent(
            eventType: "$identify",
            eventProperties: nil,
            userProperties: NSDictionary(dictionary: ["$unset": [event.userProperty: "-"]])
        )
        eventBridge.logEvent(event: analyticsEvent)
    }
}
