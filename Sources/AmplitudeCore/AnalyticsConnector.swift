//
//  AnalyticsConnector.swift
//  AmplitudeCore
//
//  Created by Brian Giori on 12/21/21.
//

import Foundation

@objc public class AnalyticsEvent: NSObject {
    @objc public let eventType: String
    @objc public let eventProperties: NSDictionary
    @objc public let userProperties: NSDictionary
    
    @objc init(eventType: String, eventProperties: NSDictionary, userProperties: NSDictionary) {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.userProperties = userProperties
    }
}

@objc public protocol AnalyticsConnector {
    @objc func setEventReceiver(_ eventReceiver: @escaping (AnalyticsEvent) -> ())
    @objc func logEvent(eventType: String, eventProperties: NSDictionary, userProperties: NSDictionary)
}

@objc internal class AnalyticsConnectorImpl: NSObject, AnalyticsConnector {
    
    private let eventReceiverLock = DispatchSemaphore(value: 1)
    private var eventReceiver: ((AnalyticsEvent) -> ())? = nil
    
    @objc func setEventReceiver(_ eventReceiver: @escaping (AnalyticsEvent) -> ()) {
        eventReceiverLock.wait()
        defer { eventReceiverLock.signal() }
        self.eventReceiver = eventReceiver
    }
    
    @objc func logEvent(eventType: String, eventProperties: NSDictionary, userProperties: NSDictionary) {
        eventReceiverLock.wait()
        defer { eventReceiverLock.signal() }
        let event = AnalyticsEvent(eventType: eventType, eventProperties: eventProperties, userProperties: userProperties)
        eventReceiver?(event)
    }
}


