//
//  SessionExposureTrackingProvider.swift
//  Experiment
//
//  Created by Brian Giori on 2/11/22.
//

import Foundation

internal class SessionExposureTrackingProvider : ExposureTrackingProvider {
    
    private let exposureTrackingProvider: ExposureTrackingProvider
    private let lock = DispatchSemaphore(value: 1)
    private var tracked = [String: String?]()
    
    init(exposureTrackingProvider: ExposureTrackingProvider) {
        self.exposureTrackingProvider = exposureTrackingProvider
    }
    
    func track(exposure: Exposure) {
        lock.wait()
        if (tracked.index(forKey: exposure.flagKey) != nil &&
                tracked[exposure.flagKey] == exposure.variant) {
            lock.signal()
            return
        } else {
            tracked[exposure.flagKey] = exposure.variant
            lock.signal()
        }
        exposureTrackingProvider.track(exposure: exposure)
    }
}
