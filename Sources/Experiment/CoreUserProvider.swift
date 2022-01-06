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
        let identity = identityStore.getIdentity()
        return baseUserProvider.getUser().copyToBuilder()
            .userId(identity.userId)
            .deviceId(identity.deviceId)
            .userProperties(identity.userProperties as? [String:Any])
            .build()
    }
}
