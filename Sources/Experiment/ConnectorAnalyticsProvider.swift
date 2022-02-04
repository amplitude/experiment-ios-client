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
        let source = VariantSource(rawValue: event.properties["source"] ?? "local-storage") ?? VariantSource.LocalStorage
        var eventProperties = [
            "flag_key": event.key,
        ]
        if let variant = source.isFallback() ? nil : event.variant.value {
            eventProperties["variant"] = variant
        }
        let analyticsEvent = AnalyticsEvent(
            eventType: "$exposure",
            eventProperties: NSDictionary(dictionary: eventProperties),
            userProperties: nil
        )
        eventBridge.logEvent(event: analyticsEvent)
    }
    
    func setUserProperty(_ event: ExperimentAnalyticsEvent) {
    }
    
    func unsetUserProperty(_ event: ExperimentAnalyticsEvent) {
        track(event)
    }
}
