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

internal class ConnectorUserProvider : ExperimentUserProvider {
    
    private let identityStore: IdentityStore
    private let baseUserProvider = DefaultUserProvider()
    private var identity: Identity? = nil
    private let identityLock = DispatchSemaphore(value: 1)
    
    private let id: String = randomString(length: 16)
    
    init(identityStore: IdentityStore) {
        self.identityStore = identityStore
        self.identityStore.addIdentityListener(key: id) { (updatedId) in
            self.identityLock.wait()
            defer { self.identityLock.signal() }
            self.identity = copyId(updatedId)
        }
        self.identityLock.wait()
        defer { self.identityLock.signal() }
        self.identity = self.identityStore.getIdentity()
    }
    
    
    func getUser() -> ExperimentUser {
        self.identityLock.wait()
        defer { self.identityLock.signal() }
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity?.userId)
            .deviceId(identity?.deviceId)
            .userProperties(identity?.userProperties as? [String:Any])
            .build()
    }
    
    func getUserOrWait(timeout: DispatchTimeInterval) throws -> ExperimentUser {
        self.identityLock.wait()
        if identity == nil {
            self.identityLock.signal()
            try waitForIdentity(timeout: timeout)
            self.identityLock.wait()
        }
        defer { self.identityLock.signal() }
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity?.userId)
            .deviceId(identity?.deviceId)
            .userProperties(identity?.userProperties as? [String:Any])
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
