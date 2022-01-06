//
//  AnalyticsConnectorTests.swift
//  AmplitudeCoreTests
//
//  Created by Brian Giori on 12/22/21.
//

import XCTest
@testable import AmplitudeCore


class AnalyticsConnectorTests: XCTestCase {
    
    func testAddEventListenerLogEventListenerCalled() {
        let testEvent = AnalyticsEvent(eventType: "test", eventProperties: nil, userProperties: nil)
        let analyticsConnector = AnalyticsConnectorImpl()
        analyticsConnector.setEventReceiver { (event) in
            XCTAssertEqual(testEvent, event)
        }
        analyticsConnector.logEvent(event: AnalyticsEvent(eventType: "test", eventProperties: nil, userProperties: nil))
    }
    
    func testMultipleLogEventLateAddEventListenerListenerCalled() {
        let testEvent0 = AnalyticsEvent(eventType: "test0", eventProperties: nil, userProperties: nil)
        let testEvent1 = AnalyticsEvent(eventType: "test1", eventProperties: nil, userProperties: nil)
        let testEvent2 = AnalyticsEvent(eventType: "test2", eventProperties: nil, userProperties: nil)
        let analyticsConnector = AnalyticsConnectorImpl()
        analyticsConnector.logEvent(event: testEvent0)
        analyticsConnector.logEvent(event: testEvent1)
        var eventCount = 0
        analyticsConnector.setEventReceiver { (event) in
            if eventCount == 0 {
                XCTAssertEqual(testEvent0, event)
            } else if eventCount == 1 {
                XCTAssertEqual(testEvent1, event)
            } else if eventCount == 2 {
                XCTAssertEqual(testEvent2, event)
            }
            eventCount += 1
        }
        analyticsConnector.logEvent(event: testEvent2)
        XCTAssertEqual(3, eventCount)
    }
}
