//
//  ConnectorAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AnalyticsConnector

internal class ConnectorExposureTrackingProvider : ExposureTrackingProvider {
    
    private let eventBridge: EventBridge
    
    internal init(eventBridge: EventBridge) {
        self.eventBridge = eventBridge
    }
    
    func track(exposure: Exposure) {
        var eventProperties = ["flag_key": exposure.flagKey]
        if let variant = exposure.variant {
            eventProperties["variant"] = variant
        }
        eventBridge.logEvent(event: AnalyticsEvent(
            eventType: "$exposure",
            eventProperties: NSDictionary(dictionary: eventProperties),
            userProperties: nil
        ))
    }
}
