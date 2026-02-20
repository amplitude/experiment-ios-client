//
//  AmplitudeContextProvider.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public final class DefaultUserProvider : NSObject, ExperimentUserProvider, Sendable {
    
    private let userId: String?
    private let deviceId: String?
    private let version: String?
    private let language: String?
    private let platform: String
    private let os: String
    private let deviceManufacturer: String
    private let deviceModel: String

    @objc public init(userId: String? = nil, deviceId: String? = nil) {
        self.userId = userId
        self.deviceId = deviceId
        self.version = DefaultUserProvider.getVersion()
        self.language = DefaultUserProvider.getLanguage()
        self.platform = DefaultUserProvider.getPlatform()
        self.os = DefaultUserProvider.getOs()
        self.deviceManufacturer = DefaultUserProvider.getDeviceManufacturer()
        self.deviceModel = DefaultUserProvider.getDeviceModel()
    }
    
    @objc public func getUser() -> ExperimentUser {
        return ExperimentUserBuilder()
            .deviceId(deviceId)
            .userId(userId)
            .version(version)
            .language(language)
            .platform(platform)
            .os(os)
            .deviceManufacturer(deviceManufacturer)
            .deviceModel(deviceModel)
            .build()
    }
    
    private static func getVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private static func getLanguage() -> String? {
        return Locale(identifier: "en_US").localizedString(forLanguageCode: Locale.preferredLanguages[0])
    }

    private static func getPlatform() -> String {
        #if os(OSX)
            return "macOS"
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(visionOS)
            return "visionOS"
        #elseif os(iOS)
            #if targetEnvironment(macCatalyst)
                return "macOS"
            #else
                return "iOS"
            #endif
        #else
            return "iOS"
        #endif
    }

    private static func getOs() -> String {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let os = getPlatform().lowercased() + " \(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)."
        return os
    }

    private static func getDeviceManufacturer() -> String {
        return "Apple"
    }

    private static func getPlatformString() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    private static func getDeviceModel() -> String {
        let platform = getPlatformString()
        // == iPhone ==
        // iPhone 1
        if (platform == "iPhone1,1") { return "iPhone 1" }
        // iPhone 3
        if (platform == "iPhone1,2") { return "iPhone 3G" }
        if (platform == "iPhone2,1") { return "iPhone 3GS" }
        // iPhone 4
        if (platform == "iPhone3,1") { return "iPhone 4" }
        if (platform == "iPhone3,2") { return "iPhone 4" }
        if (platform == "iPhone3,3") { return "iPhone 4" }
        if (platform == "iPhone4,1") { return "iPhone 4S" }
        // iPhone 5
        if (platform == "iPhone5,1") { return "iPhone 5" }
        if (platform == "iPhone5,2") { return "iPhone 5" }
        if (platform == "iPhone5,3") { return "iPhone 5c" }
        if (platform == "iPhone5,4") { return "iPhone 5c" }
        if (platform == "iPhone6,1") { return "iPhone 5s" }
        if (platform == "iPhone6,2") { return "iPhone 5s" }
        // iPhone 6
        if (platform == "iPhone7,1") { return "iPhone 6 Plus" }
        if (platform == "iPhone7,2") { return "iPhone 6" }
        if (platform == "iPhone8,1") { return "iPhone 6s" }
        if (platform == "iPhone8,2") { return "iPhone 6s Plus" }

        // iPhone 7
        if (platform == "iPhone9,1") { return "iPhone 7" }
        if (platform == "iPhone9,2") { return "iPhone 7 Plus" }
        if (platform == "iPhone9,3") { return "iPhone 7" }
        if (platform == "iPhone9,4") { return "iPhone 7 Plus" }
        // iPhone 8
        if (platform == "iPhone10,1") { return "iPhone 8" }
        if (platform == "iPhone10,4") { return "iPhone 8" }
        if (platform == "iPhone10,2") { return "iPhone 8 Plus" }
        if (platform == "iPhone10,5") { return "iPhone 8 Plus" }

        // iPhone X
        if (platform == "iPhone10,3") { return "iPhone X" }
        if (platform == "iPhone10,6") { return "iPhone X" }

        // iPhone XS
        if (platform == "iPhone11,2") { return "iPhone XS" }
        if (platform == "iPhone11,4") { return "iPhone XS Max" }
        if (platform == "iPhone11,6") { return "iPhone XS Max" }

        // iPhone XR
        if (platform == "iPhone11,8") { return "iPhone XR" }

        // iPhone 11
        if (platform == "iPhone12,1") { return "iPhone 11" }
        if (platform == "iPhone12,3") { return "iPhone 11 Pro" }
        if (platform == "iPhone12,5") { return "iPhone 11 Pro Max" }
        
        // iPhone 12
        if (platform == "iPhone13,1") { return "iPhone 12 Mini" }
        if (platform == "iPhone13,2") { return "iPhone 12" }
        if (platform == "iPhone13,3") { return "iPhone 12 Pro" }
        if (platform == "iPhone13,4") { return "iPhone 12 Pro Max" }
        

        // iPhone 13
        if (platform == "iPhone14,2") { return "iPhone 13 Pro" }
        if (platform == "iPhone14,3") { return "iPhone 13 Pro Max" }
        if (platform == "iPhone14,4") { return "iPhone 13 Mini" }
        if (platform == "iPhone14,5") { return "iPhone 13" }
        
        // iPhone 14
        if (platform == "iPhone14,7") { return "iPhone 14" }
        if (platform == "iPhone14,8") { return "iPhone 14 Plus" }
        if (platform == "iPhone15,2") { return "iPhone 14 Pro" }
        if (platform == "iPhone15,3") { return "iPhone 14 Pro Max" }
        
        // iPhone 15
        if (platform == "iPhone15,4") { return "iPhone 15" }
        if (platform == "iPhone15,5") { return "iPhone 15 Plus" }
        if (platform == "iPhone16,1") { return "iPhone 15 Pro" }
        if (platform == "iPhone16,2") { return "iPhone 15 Pro Max" }
        
        // iPhone 16
        if (platform == "iPhone17,1") { return "iPhone 16 Pro" }
        if (platform == "iPhone17,2") { return "iPhone 16 Pro Max" }
        if (platform == "iPhone17,3") { return "iPhone 16" }
        if (platform == "iPhone17,4") { return "iPhone 16 Plus" }

        // iPhone SE
        if (platform == "iPhone8,4") { return "iPhone SE" }
        if (platform == "iPhone12,8") { return "iPhone SE 2" }
        if (platform == "iPhone14,6") { return "iPhone SE 3" }

        // == iPod ==
        if (platform == "iPod1,1") { return "iPod Touch 1G" }
        if (platform == "iPod2,1") { return "iPod Touch 2G" }
        if (platform == "iPod3,1") { return "iPod Touch 3G" }
        if (platform == "iPod4,1") { return "iPod Touch 4G" }
        if (platform == "iPod5,1") { return "iPod Touch 5G" }
        if (platform == "iPod7,1") { return "iPod Touch 6G" }
        if (platform == "iPod9,1") { return "iPod Touch 7G" }

        // == iPad ==
        // iPad 1
        if (platform == "iPad1,1") { return "iPad 1" }
        if (platform == "iPad1,2") { return "iPad 1" }
        // iPad 2
        if (platform == "iPad2,1") { return "iPad 2" }
        if (platform == "iPad2,2") { return "iPad 2" }
        if (platform == "iPad2,3") { return "iPad 2" }
        if (platform == "iPad2,4") { return "iPad 2" }
        // iPad 3
        if (platform == "iPad3,1") { return "iPad 3" }
        if (platform == "iPad3,2") { return "iPad 3" }
        if (platform == "iPad3,3") { return "iPad 3" }
        // iPad 4
        if (platform == "iPad3,4") { return "iPad 4" }
        if (platform == "iPad3,5") { return "iPad 4" }
        if (platform == "iPad3,6") { return "iPad 4" }
        // iPad Air
        if (platform == "iPad4,1") { return "iPad Air" }
        if (platform == "iPad4,2") { return "iPad Air" }
        if (platform == "iPad4,3") { return "iPad Air" }
        // iPad Air 2
        if (platform == "iPad5,3") { return "iPad Air 2" }
        if (platform == "iPad5,4") { return "iPad Air 2" }
        // iPad 5
        if (platform == "iPad6,11") { return "iPad 5" }
        if (platform == "iPad6,12") { return "iPad 5" }
        // iPad 6
        if (platform == "iPad7,5") { return "iPad 6" }
        if (platform == "iPad7,6") { return "iPad 6" }
        // iPad Air 3
        if (platform == "iPad11,3") { return "iPad Air 3" }
        if (platform == "iPad11,4") { return "iPad Air 3" }
        // iPad 7
        if (platform == "iPad7,11") { return "iPad 6" }
        if (platform == "iPad7,12") { return "iPad 6" }
        if (platform == "iPad11,6") { return "iPad 8th Gen (WiFi)" }
        if (platform == "iPad11,7") { return "iPad 8th Gen (WiFi+Cellular)" }
        if (platform == "iPad12,1") { return "iPad 9th Gen (WiFi)" }
        if (platform == "iPad12,2") { return "iPad 9th Gen (WiFi+Cellular)" }
        if (platform == "iPad13,1") { return "iPad Air 4th Gen (WiFi)" }
        if (platform == "iPad13,2") { return "iPad Air 4th Gen (WiFi+Cellular)" }
        if (platform == "iPad13,16") { return "iPad Air 5th Gen (WiFi)" }
        if (platform == "iPad13,17") { return "iPad Air 5th Gen (WiFi+Cellular)" }
        if (platform == "iPad13,18") { return "iPad 10th Gen" }
        if (platform == "iPad13,19") { return "iPad 10th Gen" }
        if (platform == "iPad14,8") { return "iPad Air 6th Gen" }
        if (platform == "iPad14,9") { return "iPad Air 6th Gen" }
        if (platform == "iPad14,10") { return "iPad Air 7th Gen" }
        if (platform == "iPad14,11") { return "iPad Air 7th Gen" }

        // iPad Pro
        if (platform == "iPad6,3") { return "iPad Pro" }
        if (platform == "iPad6,4") { return "iPad Pro" }
        if (platform == "iPad6,7") { return "iPad Pro" }
        if (platform == "iPad6,8") { return "iPad Pro" }
        if (platform == "iPad7,1") { return "iPad Pro" }
        if (platform == "iPad7,2") { return "iPad Pro" }
        if (platform == "iPad7,3") { return "iPad Pro" }
        if (platform == "iPad7,4") { return "iPad Pro" }
        if (platform == "iPad8,1") { return "iPad Pro" }
        if (platform == "iPad8,2") { return "iPad Pro" }
        if (platform == "iPad8,3") { return "iPad Pro" }
        if (platform == "iPad8,4") { return "iPad Pro" }
        if (platform == "iPad8,5") { return "iPad Pro" }
        if (platform == "iPad8,6") { return "iPad Pro" }
        if (platform == "iPad8,7") { return "iPad Pro" }
        if (platform == "iPad8,8") { return "iPad Pro" }
        if (platform == "iPad8,9") { return "iPad Pro" }
        if (platform == "iPad8,10") { return "iPad Pro" }
        if (platform == "iPad8,11") { return "iPad Pro" }
        if (platform == "iPad8,12") { return "iPad Pro" }
        if (platform == "iPad13,4") { return "iPad Pro" }
        if (platform == "iPad13,5") { return "iPad Pro" }
        if (platform == "iPad13,6") { return "iPad Pro" }
        if (platform == "iPad13,7") { return "iPad Pro" }
        if (platform == "iPad13,8") { return "iPad Pro" }
        if (platform == "iPad13,9") { return "iPad Pro" }
        if (platform == "iPad13,10") { return "iPad Pro" }
        if (platform == "iPad13,11") { return "iPad Pro" }
        if (platform == "iPad14,3") { return "iPad Pro" }
        if (platform == "iPad14,4") { return "iPad Pro" }
        if (platform == "iPad14,5") { return "iPad Pro" }
        if (platform == "iPad14,6") { return "iPad Pro" }
        if (platform == "iPad16,3") { return "iPad Pro" }
        if (platform == "iPad16,4") { return "iPad Pro" }
        if (platform == "iPad16,5") { return "iPad Pro" }
        if (platform == "iPad16,6") { return "iPad Pro" }

        // iPad Mini
        if (platform == "iPad2,5") { return "iPad Mini" }
        if (platform == "iPad2,6") { return "iPad Mini" }
        if (platform == "iPad2,7") { return "iPad Mini" }
        // iPad Mini 2
        if (platform == "iPad4,4") { return "iPad Mini 2" }
        if (platform == "iPad4,5") { return "iPad Mini 2" }
        if (platform == "iPad4,6") { return "iPad Mini 2" }
        // iPad Mini 3
        if (platform == "iPad4,7") { return "iPad Mini 3" }
        if (platform == "iPad4,8") { return "iPad Mini 3" }
        if (platform == "iPad4,9") { return "iPad Mini 3" }
        // iPad Mini 4
        if (platform == "iPad5,1") { return "iPad Mini 4" }
        if (platform == "iPad5,2") { return "iPad Mini 4" }
        // iPad Mini 5
        if (platform == "iPad11,1") { return "iPad Mini 5" }
        if (platform == "iPad11,2") { return "iPad Mini 5" }
        if (platform == "iPad14,1") { return "iPad mini 6" }
        if (platform == "iPad14,2") { return "iPad mini 6" }

        // == Apple Watch ==
        if (platform == "Watch1,1") { return "Apple Watch 38mm" }
        if (platform == "Watch1,2") { return "Apple Watch 42mm" }
        if (platform == "Watch2,3") { return "Apple Watch Series 2 38mm" }
        if (platform == "Watch2,4") { return "Apple Watch Series 2 42mm" }
        if (platform == "Watch2,6") { return "Apple Watch Series 1 38mm" }
        if (platform == "Watch2,7") { return "Apple Watch Series 1 42mm" }
        if (platform == "Watch3,1") { return "Apple Watch Series 3 38mm Cellular" }
        if (platform == "Watch3,2") { return "Apple Watch Series 3 42mm Cellular" }
        if (platform == "Watch3,3") { return "Apple Watch Series 3 38mm" }
        if (platform == "Watch3,4") { return "Apple Watch Series 3 42mm" }
        if (platform == "Watch4,1") { return "Apple Watch Series 4 40mm" }
        if (platform == "Watch4,2") { return "Apple Watch Series 4 44mm" }
        if (platform == "Watch4,3") { return "Apple Watch Series 4 40mm Cellular" }
        if (platform == "Watch4,4") { return "Apple Watch Series 4 44mm Cellular" }
        if (platform == "Watch5,1") { return "Apple Watch Series 5 40mm" }
        if (platform == "Watch5,2") { return "Apple Watch Series 5 44mm" }
        if (platform == "Watch5,3") { return "Apple Watch Series 5 40mm Cellular" }
        if (platform == "Watch5,4") { return "Apple Watch Series 5 44mm Cellular" }
        if (platform == "Watch5,9") { return "Apple Watch SE 40mm case" }
        if (platform == "Watch5,10") { return "Apple Watch SE 44mm case" }
        if (platform == "Watch5,11") { return "Apple Watch SE 40mm case Cellular" }
        if (platform == "Watch5,12") { return "Apple Watch SE 44mm case Cellular" }
        if (platform == "Watch6,1") { return "Apple Watch Series 6 40mm" }
        if (platform == "Watch6,2") { return "Apple Watch Series 6 44mm" }
        if (platform == "Watch6,3") { return "Apple Watch Series 6 40mm Cellular" }
        if (platform == "Watch6,4") { return "Apple Watch Series 6 44mm Cellular" }
        if (platform == "Watch6,6") { return "Apple Watch Series 7 41mm case" }
        if (platform == "Watch6,7") { return "Apple Watch Series 7 45mm case" }
        if (platform == "Watch6,8") { return "Apple Watch Series 7 41mm case Cellular" }
        if (platform == "Watch6,9") { return "Apple Watch Series 7 45mm case Cellular" }
        if (platform == "Watch6,10") { return "Apple Watch SE 40mm case" }
        if (platform == "Watch6,11") { return "Apple Watch SE 44mm case" }
        if (platform == "Watch6,12") { return "Apple Watch SE 40mm case Cellular" }
        if (platform == "Watch6,13") { return "Apple Watch SE 44mm case Cellular" }
        if (platform == "Watch6,14") { return "Apple Watch Series 8 41mm case" }
        if (platform == "Watch6,15") { return "Apple Watch Series 8 45mm case" }
        if (platform == "Watch6,16") { return "Apple Watch Series 8 41mm case Cellular" }
        if (platform == "Watch6,17") { return "Apple Watch Series 8 45mm case Cellular" }
        if (platform == "Watch6,18") { return "Apple Watch Ultra" }
        if (platform == "Watch7,1") { return "Apple Watch Series 9 41mm case" }
        if (platform == "Watch7,2") { return "Apple Watch Series 9 45mm case" }
        if (platform == "Watch7,3") { return "Apple Watch Series 9 41mm case Cellular" }
        if (platform == "Watch7,4") { return "Apple Watch Series 9 45mm case Cellular" }
        if (platform == "Watch7,5") { return "Apple Watch Ultra 2" }

        // == Others ==
        if (platform == "i386") { return "Simulator" }
        if (platform == "x86_64") { return "Simulator" }
        if (platform == "arm64") { return "Simulator" }
        if (platform.hasPrefix("MacBookAir")) { return "MacBook Air" }
        if (platform.hasPrefix("MacBookPro")) { return "MacBook Pro" }
        if (platform.hasPrefix("MacBook")) { return "MacBook" }
        if (platform.hasPrefix("MacPro")) { return "Mac Pro" }
        if (platform.hasPrefix("Macmini")) { return "Mac Mini" }
        if (platform.hasPrefix("iMac")) { return "iMac" }
        if (platform.hasPrefix("Xserve")) { return "Xserve" }
        return platform
    }
}
