//
//  ContextProvider.swift
//  Skylab
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public protocol ContextProvider {
    func getDeviceId() -> String?
    func getUserId() -> String?
    func getVersion() -> String?
    func getLanguage() -> String?
    func getPlatform() -> String?
    func getOs() -> String?
    func getDeviceManufacturer() -> String?
    func getDeviceModel() -> String?
}

