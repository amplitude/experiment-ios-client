//
//  CoreUserProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AmplitudeCore

internal class CoreUserProvider : ExperimentUserProvider {
    
    private let identityStore: IdentityStore
    private let baseUserProvider = DefaultUserProvider()
    
    init(identityStore: IdentityStore) {
        self.identityStore = identityStore
    }
    
    func getUser() -> ExperimentUser {
        let identity = self.identityStore.getIdentity()
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String:Any])
            .build()
    }
    
    func getUserOrWait(timeout: DispatchTimeInterval) throws -> ExperimentUser {
        let identity = try getIdentityOrWait(timeout: timeout)
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String:Any])
            .build()
    }
    
    private func getIdentityOrWait(timeout: DispatchTimeInterval) throws -> Identity {
        let listenerId = self.randomString(length: 16)
        let lock = DispatchSemaphore(value: 0)
        var listenerIdentity = Identity()
        identityStore.addIdentityListener(key: listenerId) { (identity) in
            listenerIdentity = identity
            lock.signal()
        }
        defer { identityStore.removeIdentityListener(key: listenerId) }
        let immediateIdentity = identityStore.getIdentity()
        if immediateIdentity.userId == nil && immediateIdentity.deviceId == nil {
            let result = lock.wait(timeout: .now() + timeout)
            if result == .timedOut {
                throw ExperimentError("Timed out waiting for Amplitude Analytics SDK to initialize. You must ensure that the analytics SDK is initialized prior to calling fetch().")
            }
            return listenerIdentity
        } else {
            return immediateIdentity
        }
    }
    
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
