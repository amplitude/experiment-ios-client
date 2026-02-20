//
//  ConnectorAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AnalyticsConnector

internal class ConnectorExposureTrackingProvider : ExposureTrackingProvider, @unchecked Sendable {
    // @unchecked Sendable: Assuming EventBridge handles its own concurrencies and is Sendable.
    
    private let eventBridge: EventBridge
    
    internal init(eventBridge: EventBridge) {
        self.eventBridge = eventBridge
    }
    
    func track(exposure: Exposure) {
        let eventProperties = NSMutableDictionary()
        eventProperties.setValue(exposure.flagKey, forKey: "flag_key")
        if let variant = exposure.variant {
            eventProperties.setValue(variant, forKey: "variant")
        }
        if let experimentKey = exposure.experimentKey {
            eventProperties.setValue(experimentKey, forKey: "experiment_key")
        }
        if let metadata = exposure.metadata {
            eventProperties.setValue(metadata, forKey: "metadata")
        }
        eventBridge.logEvent(event: AnalyticsEvent(
            eventType: "$exposure",
            eventProperties: eventProperties,
            userProperties: nil
        ))
    }
}
