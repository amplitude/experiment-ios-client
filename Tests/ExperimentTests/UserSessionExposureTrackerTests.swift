//
//  UserSessionExposureTrackerTests.swift
//  ExperimentTests
//
//  Created by Brian Giori on 4/15/22.
//

import Foundation
@testable import Experiment
import XCTest

class TestExposureTrackingProvider: ExposureTrackingProvider {
    
    public var lastExposure: Exposure? = nil
    public var trackCount = 0
    
    func track(exposure: Exposure) {
        trackCount += 1
        lastExposure = exposure
    }
}

class UserSessionExposureTrackerTests : XCTestCase {
    
    func testTrackCalledOncePerFlag() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(1, provider.trackCount)
        
        let exposure2 = Exposure(flagKey: "flag2", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure2)
        }
        XCTAssertEqual(exposure2, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnSameFlagWithVariantChangeValueToNull() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        let exposure2 = Exposure(flagKey: "flag", variant: nil)
        for _ in 0...10 {
            tracker.track(exposure: exposure2)
        }
        
        XCTAssertEqual(exposure2, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnSameFlagWithVariantChangeValueToDifferentValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        let exposure2 = Exposure(flagKey: "flag", variant: nil)
        for _ in 0...10 {
            tracker.track(exposure: exposure2)
        }
        
        XCTAssertEqual(exposure2, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdChangeNullToValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnDeviceIdChangeNullToValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().deviceId("did").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdChangeValueToNull() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUser())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnDeviceIdChangeValueToNull() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().deviceId("did").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUser())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdChangeValueToDifferentValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid2").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnDeviceIdChangeValueToDifferentValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().deviceId("did").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().deviceId("did2").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdAndDeviceIdChangeNullToValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure)
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").deviceId("did").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdAndDeviceIdChangeValueToNull() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").deviceId("did").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUser())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
    
    func testTrackCalledAgainOnUserIdAndDeviceIdChangeValueToDifferentValue() {
        let provider = TestExposureTrackingProvider()
        let tracker = UserSessionExposureTracker(exposureTrackingProvider: provider)
        
        let exposure = Exposure(flagKey: "flag", variant: "variant")
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid").deviceId("did").build())
        }
        for _ in 0...10 {
            tracker.track(exposure: exposure, user: ExperimentUserBuilder().userId("uid2").deviceId("did2").build())
        }
        
        XCTAssertEqual(exposure, provider.lastExposure)
        XCTAssertEqual(2, provider.trackCount)
    }
}
