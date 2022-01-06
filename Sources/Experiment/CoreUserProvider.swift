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
        let identity = getIdentityOrWait()
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String:Any])
            .build()
    }
    
    private func getIdentityOrWait() -> Identity {
        let listenerId = randomString(length: 16)
        let lock = DispatchSemaphore(value: 1)
        var listenerIdentity: Identity? = nil
        identityStore.addIdentityListener(key: listenerId) { (identity) in
            listenerIdentity = identity
            lock.signal()
        }
        defer { identityStore.removeIdentityListener(key: listenerId) }
        let immediateIdentity = identityStore.getIdentity()
        if immediateIdentity.userId == nil && immediateIdentity.deviceId == nil {
            lock.wait()
            return listenerIdentity ?? immediateIdentity
        } else {
            return immediateIdentity
        }
    }
    
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
