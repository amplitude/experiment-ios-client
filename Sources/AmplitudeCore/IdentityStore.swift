//
//  IdentityStore.swift
//  AmplitudeCore
//
//  Created by Brian Giori on 12/21/21.
//

import Foundation

@objc public class Identity: NSObject {
    @objc public let userId: String?
    @objc public let deviceId: String?
    @objc public let userProperties: NSDictionary?
    @objc public init(userId: String? = nil, deviceId: String? = nil, userProperties: NSDictionary? = nil) {
        self.userId = userId
        self.deviceId = deviceId
        self.userProperties = userProperties
    }
}

@objc public protocol IdentityStore {
    func getIdentity() -> Identity
    func setIdentity(_ identity: Identity)
    func editIdentity() -> IdentityStoreEditor
}

@objc public protocol IdentityStoreEditor {
    func setUserId(_ userId: String) -> IdentityStoreEditor
    func setDeviceId(_ deviceId: String) -> IdentityStoreEditor
    func setUserProperties(_ userProperties: NSDictionary) -> IdentityStoreEditor
    func editUserProperties(_ userPropertyActions: NSDictionary) -> IdentityStoreEditor
    func commit()
}

@objc internal class IdentityStoreImpl: NSObject, IdentityStore {
    private let identityLock = DispatchSemaphore(value: 1)
    private var identity = Identity()
    
    func getIdentity() -> Identity {
        identityLock.wait()
        defer { identityLock.signal() }
        return identity
    }
    
    func setIdentity(_ identity: Identity) {
        identityLock.wait()
        defer { identityLock.signal() }
        self.identity = identity
    }
    
    func editIdentity() -> IdentityStoreEditor {
        return IdentityStoreEditorImpl(identityStore: self)
    }
}

@objc internal class IdentityStoreEditorImpl: NSObject, IdentityStoreEditor {
    
    private let identityStore: IdentityStore
    
    private var userId: String?
    private var deviceId: String?
    private var userProperties: NSDictionary?
    
    internal init(identityStore: IdentityStore) {
        let identity = identityStore.getIdentity()
        self.userId = identity.userId
        self.deviceId = identity.deviceId
        self.userProperties = identity.userProperties
        self.identityStore = identityStore
    }
    
    func setUserId(_ userId: String) -> IdentityStoreEditor {
        self.userId = userId
        return self
    }
    
    func setDeviceId(_ deviceId: String) -> IdentityStoreEditor {
        self.deviceId = deviceId
        return self
    }
    
    func setUserProperties(_ userProperties: NSDictionary) -> IdentityStoreEditor {
        self.userProperties = userProperties
        return self
    }
    
    func editUserProperties(_ userPropertyActions: NSDictionary) -> IdentityStoreEditor {
        // TODO
        return self
    }
    
    func commit() {
        let identity = Identity(userId: userId, deviceId: deviceId, userProperties: userProperties)
        self.identityStore.setIdentity(identity)
    }
    
    
}
