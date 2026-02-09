//
//  ConnectorUserProvider.swift
//  Experiment
//
//  Created by Brian Giori on 1/6/22.
//

import Foundation
import AnalyticsConnector

func copyId(_ identity: Identity) -> Identity {
    return Identity(userId: identity.userId, deviceId: identity.deviceId, userProperties: identity.userProperties)
}

// TODO This class needs a rewrite.
internal final class ConnectorUserProvider : ExperimentUserProvider, @unchecked Sendable {
    // @unchecked Sendable:
    // Assumed IdentityStore is Sendable.
    // var initialized is guarded.
    
    private let identityStore: IdentityStore
    private let baseUserProvider = DefaultUserProvider()
    private var initialized: Bool = false
    private let initializedLock = DispatchSemaphore(value: 1)
        
    init(identityStore: IdentityStore) {
        self.identityStore = identityStore
        let id: String = randomString(length: 16)
        self.identityStore.addIdentityListener(key: id) { (updatedId) in
            self.initializedLock.wait()
            defer { self.initializedLock.signal() }
            self.initialized = true
            self.identityStore.removeIdentityListener(key: id)
        }
    }
    
    
    func getUser() -> ExperimentUser {
        self.initializedLock.wait()
        defer { self.initializedLock.signal() }
        let identity = copyId(identityStore.getIdentity())
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String: any Sendable])
            .build()
    }
    
    func getUserOrWait(timeout: DispatchTimeInterval) throws -> ExperimentUser {
        self.initializedLock.wait()
        if !initialized {
            self.initializedLock.signal()
            try waitForIdentity(timeout: timeout)
            self.initializedLock.wait()
        }
        defer { self.initializedLock.signal() }
        let identity = copyId(identityStore.getIdentity())
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String: any Sendable])
            .build()
    }
    
    private func waitForIdentity(timeout: DispatchTimeInterval) throws {
        let listenerId = randomString(length: 16)
        let lock = DispatchSemaphore(value: 0)
        identityStore.addIdentityListener(key: listenerId) { (identity) in
            lock.signal()
        }
        defer { identityStore.removeIdentityListener(key: listenerId) }
        let immediateIdentity = identityStore.getIdentity()
        if immediateIdentity.userId == nil && immediateIdentity.deviceId == nil {
            let result = lock.wait(timeout: .now() + timeout)
            if result == .timedOut {
                throw ExperimentError("Timed out waiting for Amplitude Analytics SDK to initialize. You must ensure that the analytics SDK is initialized prior to calling fetch().")
            }
        }
    }
}

private func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}
