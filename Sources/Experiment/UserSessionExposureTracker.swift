//
//  SessionExposureTrackingProvider.swift
//  Experiment
//
//  Created by Brian Giori on 2/11/22.
//

import Foundation
import AnalyticsConnector

internal class UserSessionExposureTracker {
    
    private let exposureTrackingProvider: ExposureTrackingProvider
    private let lock = DispatchSemaphore(value: 1)
    private var tracked = [String: String?]()
    private var identity = Identity()
    
    init(exposureTrackingProvider: ExposureTrackingProvider) {
        self.exposureTrackingProvider = exposureTrackingProvider
    }
    
    func track(exposure: Exposure, user: ExperimentUser? = nil) {
        lock.wait()
        let newIdentity = Identity(userId: user?.userId, deviceId: user?.deviceId)
        if (!identityEquals(identity, newIdentity)) {
            tracked = [:]
        }
        identity = newIdentity
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
    
    private func identityEquals(_ id1: Identity, _ id2: Identity) -> Bool {
        return id1.userId == id2.userId && id1.deviceId == id2.deviceId
    }
}
