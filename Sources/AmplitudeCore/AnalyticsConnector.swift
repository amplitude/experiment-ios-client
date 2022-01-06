//
//  AnalyticsConnector.swift
//  AmplitudeCore
//
//  Created by Brian Giori on 12/21/21.
//

import Foundation

@objc public class AnalyticsEvent: NSObject {
    @objc public let eventType: String
    @objc public let eventProperties: NSDictionary?
    @objc public let userProperties: NSDictionary?
    
    @objc public init(eventType: String, eventProperties: NSDictionary?, userProperties: NSDictionary?) {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.userProperties = userProperties
    }
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? AnalyticsEvent else {
            return false
        }
        return self.eventType == other.eventType &&
            eventProperties?.isEqual(to: other.eventProperties) ?? (other.eventProperties == nil) &&
            userProperties?.isEqual(to: other.userProperties) ?? (other.userProperties == nil)
    }
}

@objc public protocol AnalyticsConnector {
    @objc func setEventReceiver(_ eventReceiver: @escaping (AnalyticsEvent) -> ())
    @objc func logEvent(event: AnalyticsEvent)
}

@objc internal class AnalyticsConnectorImpl: NSObject, AnalyticsConnector {
    
    private let eventReceiverLock = DispatchSemaphore(value: 1)
    private var eventReceiver: ((AnalyticsEvent) -> ())? = nil
    private var eventQueue: [AnalyticsEvent] = []
    
    @objc func setEventReceiver(_ eventReceiver: @escaping (AnalyticsEvent) -> ()) {
        eventReceiverLock.wait()
        self.eventReceiver = eventReceiver
        let events = eventQueue
        eventQueue = []
        eventReceiverLock.signal()
        for event in events {
            eventReceiver(event)
        }
    }
    
    @objc func logEvent(event: AnalyticsEvent) {
        eventReceiverLock.wait()
        defer { eventReceiverLock.signal() }
        guard let eventReceiver = self.eventReceiver else {
            eventQueue.append(event)
            return
        }
        eventReceiver(event)
    }
}
