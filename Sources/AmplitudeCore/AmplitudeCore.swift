//
//  AmplitudeCore.swift
//  Experiment
//
//  Created by Brian Giori on 12/20/21.
//

import Foundation

@objc public class AmplitudeCore : NSObject {
    
    private static let instancesLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    private static var instances: [String:AmplitudeCore] = [:]
    
    @objc static func getInstance(_ instanceName: String) -> AmplitudeCore {
        instancesLock.wait()
        defer { instancesLock.signal() }
        if let instance = instances[instanceName] {
            return instance
        } else {
            instances[instanceName] = AmplitudeCore()
            return instances[instanceName]!
        }
    }
    
//    public init(analyticsConnector: AnalyticsConnector, identityStore: IdentityStore) {
//
//    }
//    public let analyticsConnector: AnalyticsConnector
//    public let identityStore: IdentityStore
}
