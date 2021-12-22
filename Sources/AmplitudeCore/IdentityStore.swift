//
//  IdentityStore.swift
//  AmplitudeCore
//
//  Created by Brian Giori on 12/21/21.
//

import Foundation

internal let ID_OP_SET = "$set"
internal let ID_OP_UNSET = "$unset"
internal let ID_OP_SET_ONCE = "$setOnce"
internal let ID_OP_ADD = "$add"
internal let ID_OP_APPEND = "$append"
internal let ID_OP_PREPEND = "$prepend"
internal let ID_OP_CLEAR_ALL = "$clearAll"

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
    private var userProperties: NSMutableDictionary
    
    internal init(identityStore: IdentityStore) {
        let identity = identityStore.getIdentity()
        self.userId = identity.userId
        self.deviceId = identity.deviceId
        self.userProperties = identity.userProperties?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
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
        if let userProperties = userProperties.mutableCopy() as? NSMutableDictionary {
            self.userProperties = userProperties
        }
        return self
    }
    
    func editUserProperties(_ userPropertyActions: NSDictionary) -> IdentityStoreEditor {
        userPropertyActions.forEach { (action: Any, properties: Any) in
            guard let action = action as? String else {
                return
            }
            guard let properties = properties as? [AnyHashable: Any] else {
                return
            }
            switch (action) {
            case ID_OP_SET:
                self.userProperties.addEntries(from: properties)
            case ID_OP_UNSET:
                self.userProperties.removeObjects(forKeys: Array(properties.keys))
            case ID_OP_SET_ONCE:
                properties.forEach { (key: AnyHashable, value: Any) in
                    guard let key = key as? String else {
                        return
                    }
                    if let _ = self.userProperties[key] {
                        return
                    } else {
                        self.userProperties[key] = value
                    }
                }
            case ID_OP_ADD:
                properties.forEach { (key: AnyHashable, value: Any) in
                    guard let key = key as? String else {
                        return
                    }
                    guard let value = value as? NSNumber else {
                        return
                    }
                    guard let currentValue = self.userProperties[key] as? NSNumber else {
                        self.userProperties[key] = value
                        return
                    }
                    self.userProperties[key] = NSNumber(value: currentValue.doubleValue + value.doubleValue)
                }
            case ID_OP_APPEND:
                properties.forEach { (key: AnyHashable, value: Any) in
                    guard let key = key as? String else {
                        return
                    }
                    guard let value = value as? [Any] else {
                        return
                    }
                    var currentValue = self.userProperties[key] as? [Any] ?? []
                    self.userProperties[key] = currentValue.append(contentsOf: value)
                }
            case ID_OP_PREPEND:
                properties.forEach { (key: AnyHashable, value: Any) in
                    guard let key = key as? String else {
                        return
                    }
                    guard var value = value as? [Any] else {
                        return
                    }
                    let currentValue = self.userProperties[key] as? [Any] ?? []
                    self.userProperties[key] = value.append(contentsOf: currentValue)
                }
            case ID_OP_CLEAR_ALL:
                self.userProperties.removeAllObjects()
            default: break
            }
        }
        return self
    }
    
    func commit() {
        let identity = Identity(userId: userId, deviceId: deviceId, userProperties: userProperties)
        self.identityStore.setIdentity(identity)
    }
}
