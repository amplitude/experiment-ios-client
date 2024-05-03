//
//  ExperimentUser.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

@objc public class ExperimentUser: NSObject {

    @objc public let deviceId: String?
    @objc public let userId: String?
    @objc public let version: String?
    @objc public let country: String?
    @objc public let region: String?
    @objc public let dma: String?
    @objc public let city: String?
    @objc public let language: String?
    @objc public let platform: String?
    @objc public let os: String?
    @objc public let deviceManufacturer: String?
    @objc public let deviceModel: String?
    @objc public let carrier: String?
    @objc public let library: String?
    @available(*, deprecated, message: "Support for non-string values added. Use the `getUserProperties()` function instead to access all user properties.")
    @objc public let userProperties: [String: String]?
    @objc private let userPropertiesAnyValue: [String: Any]?
    @objc public let groups: [String: [String]]?
    @objc public let groupProperties: [String: [String: [String: Any]]]?
    
    @objc public override init() {
        self.deviceId = nil
        self.userId = nil
        self.version = nil
        self.country = nil
        self.region = nil
        self.dma = nil
        self.city = nil
        self.language = nil
        self.platform = nil
        self.os = nil
        self.deviceManufacturer = nil
        self.deviceModel = nil
        self.carrier = nil
        self.library = nil
        self.userProperties = nil
        self.userPropertiesAnyValue = nil
        self.groups = nil
        self.groupProperties = nil
    }
    
    internal init(builder: ExperimentUserBuilder) {
        self.deviceId = builder.deviceId
        self.userId = builder.userId
        self.version = builder.version
        self.country = builder.country
        self.region = builder.region
        self.dma = builder.dma
        self.city = builder.city
        self.language = builder.language
        self.platform = builder.platform
        self.os = builder.os
        self.deviceManufacturer = builder.deviceManufacturer
        self.deviceModel = builder.deviceModel
        self.carrier = builder.carrier
        self.library = builder.library
        self.userProperties = builder.userProperties
        self.userPropertiesAnyValue = builder.userPropertiesAnyValue
        self.groups = builder.groups
        self.groupProperties = builder.groupProperties
    }
    
    internal init(builder: ExperimentUser.Builder) {
        self.deviceId = builder.deviceId
        self.userId = builder.userId
        self.version = builder.version
        self.country = builder.country
        self.region = builder.region
        self.dma = builder.dma
        self.city = builder.city
        self.language = builder.language
        self.platform = builder.platform
        self.os = builder.os
        self.deviceManufacturer = builder.deviceManufacturer
        self.deviceModel = builder.deviceModel
        self.carrier = builder.carrier
        self.library = builder.library
        self.userProperties = builder.userProperties
        self.userPropertiesAnyValue = builder.userPropertiesAnyValue
        self.groups = builder.groups
        self.groupProperties = builder.groupProperties
    }
    
    @objc override public var description: String {
        return self.toDictionary().description
    }
    
    @objc override public var debugDescription: String {
        return self.toDictionary().debugDescription
    }
    
    @objc public func copyToBuilder() -> ExperimentUserBuilder {
        return ExperimentUserBuilder()
            .deviceId(self.deviceId)
            .userId(self.userId)
            .version(self.version)
            .country(self.country)
            .region(self.region)
            .dma(self.dma)
            .city(self.city)
            .language(self.language)
            .platform(platform)
            .os(self.os)
            .deviceManufacturer(self.deviceManufacturer)
            .deviceModel(self.deviceModel)
            .carrier(self.carrier)
            .library(self.library)
            .userProperties(self.userPropertiesAnyValue)
            .groups(self.groups)
            .groupProperties(self.groupProperties)
    }
    
    func getUserProperties() -> [String: Any]? {
        return userPropertiesAnyValue
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ExperimentUser else {
            return false
        }
        
        var userPropertiesAnyValueEqual = false
        if let userPropertiesAnyValue = self.userPropertiesAnyValue, let otherUserPropertiesAnyValue = other.userPropertiesAnyValue {
            userPropertiesAnyValueEqual = NSDictionary(dictionary: userPropertiesAnyValue).isEqual(to: otherUserPropertiesAnyValue)
        } else {
            userPropertiesAnyValueEqual = userPropertiesAnyValue == nil && other.userPropertiesAnyValue == nil
        }
        
        var userPropertiesEqual = false
        if let userProperties = self.userProperties, let otherUserProperties = other.userProperties {
            userPropertiesEqual = NSDictionary(dictionary: userProperties).isEqual(to: otherUserProperties)
        } else {
            userPropertiesEqual = userProperties == nil && other.userProperties == nil
        }
        
        var groupPropertiesEqual = false
        if let selfGroupProperties = self.groupProperties, let otherGroupProperties = other.groupProperties {
            groupPropertiesEqual = NSDictionary(dictionary: selfGroupProperties).isEqual(to: otherGroupProperties)
        } else {
            groupPropertiesEqual = self.groupProperties == nil && other.groupProperties == nil
        }

        return self.deviceId == other.deviceId &&
            self.userId == other.userId &&
            self.version == other.version &&
            self.country == other.country &&
            self.region == other.region &&
            self.dma == other.dma &&
            self.city == other.city &&
            self.language == other.language &&
            self.platform == other.platform &&
            self.os == other.os &&
            self.deviceManufacturer == other.deviceManufacturer &&
            self.deviceModel == other.deviceModel &&
            self.carrier == other.carrier &&
            self.library == other.library &&
            userPropertiesAnyValueEqual &&
            userPropertiesEqual &&
            self.groups == other.groups &&
            groupPropertiesEqual
    }
    
    @available(*, deprecated, message: "Use ExperimentUserBuilder instead")
    public class Builder {

        internal var deviceId: String?
        internal var userId: String?
        internal var version: String?
        internal var country: String?
        internal var region: String?
        internal var dma: String?
        internal var city: String?
        internal var language: String?
        internal var platform: String?
        internal var os: String?
        internal var deviceManufacturer: String?
        internal var deviceModel: String?
        internal var carrier: String?
        internal var library: String?
        internal var userProperties: [String: String]?
        internal var userPropertiesAnyValue: [String: Any]?
        internal var groups: [String: [String]]?
        internal var groupProperties: [String: [String: [String: Any]]]?
        
        public init() {
            // public init
        }

        @discardableResult
        public func userId(_ userId: String?) -> Builder {
            self.userId = userId
            return self
        }

        @discardableResult
        public func deviceId(_ deviceId: String?) -> Builder {
            self.deviceId = deviceId
            return self
        }

        @discardableResult
        public func country(_ country: String?) -> Builder {
            self.country = country
            return self
        }

        @discardableResult
        public func region(_ region: String?) -> Builder {
            self.region = region
            return self
        }

        @discardableResult
        public func city(_ city: String?) -> Builder {
            self.city = city
            return self
        }

        @discardableResult
        public func language(_ language: String?) -> Builder {
            self.language = language
            return self
        }

        @discardableResult
        public func platform(_ platform: String?) -> Builder {
            self.platform = platform
            return self
        }

        @discardableResult
        public func version(_ version: String?) -> Builder {
            self.version = version
            return self
        }

        @discardableResult
        public func dma(_ dma: String?) -> Builder {
            self.dma = dma
            return self
        }

        @discardableResult
        public func os(_ os: String?) -> Builder {
            self.os = os
            return self
        }

        @discardableResult
        public func deviceManufacturer(_ deviceManufacturer: String?) -> Builder {
            self.deviceManufacturer = deviceManufacturer
            return self
        }

        @discardableResult
        public func deviceModel(_ deviceModel: String?) -> Builder {
            self.deviceModel = deviceModel
            return self
        }

        @discardableResult
        public func carrier(_ carrier: String?) -> Builder {
            self.carrier = carrier
            return self
        }

        @discardableResult
        public func library(_ library: String?) -> Builder {
            self.library = library
            return self
        }

        @discardableResult
        public func userProperties(_ userProperties: [String: Any]?) -> Builder {
            guard let userProperties = userProperties else {
                self.userProperties = nil
                self.userPropertiesAnyValue = nil
                return self
            }
            for (k, v) in userProperties {
                _ = self.userProperty(k, value: v)
            }
            return self
        }

        @discardableResult
        public func userProperty(_ property: String, value: Any) -> Builder {
            if let stringValue = value as? String {
                if self.userProperties == nil {
                    self.userProperties = [property: stringValue]
                } else {
                    self.userProperties![property] = stringValue
                }
            }
            if self.userPropertiesAnyValue == nil {
                self.userPropertiesAnyValue = [property: value]
            } else {
                self.userPropertiesAnyValue![property] = value
            }
            return self
        }

        @discardableResult
        public func groups(_ groups: [String: [String]]?) -> Builder {
            self.groups = groups
            return self
        }
        
        @discardableResult
        public func group(type: String, name: String) -> Builder {
            var groups = self.groups ?? [:]
            groups[type] = [name]
            self.groups = groups
            return self
        }
        
        @discardableResult
        public func groupProperties(_ groupProperties: [String: [String: [String: Any]]]?) -> Builder {
            self.groupProperties = groupProperties
            return self
        }
        
        @discardableResult
        public func groupProperty(type: String, name: String, key: String, value: String) -> Builder {
            guard self.groupProperties?[type] != nil else {
                self.groupProperties = [type:[name:[key:value]]]
                return self
            }
            guard self.groupProperties?[type]?[name] != nil else {
                self.groupProperties?[type] = [name:[key:value]]
                return self
            }
            self.groupProperties?[type]?[name]?[key] = value
            return self
        }

        public func build() -> ExperimentUser {
            return ExperimentUser(builder: self)
        }
    }
}

@objc public class ExperimentUserBuilder : NSObject {
    
    internal var deviceId: String?
    internal var userId: String?
    internal var version: String?
    internal var country: String?
    internal var region: String?
    internal var dma: String?
    internal var city: String?
    internal var language: String?
    internal var platform: String?
    internal var os: String?
    internal var deviceManufacturer: String?
    internal var deviceModel: String?
    internal var carrier: String?
    internal var library: String?
    internal var userProperties: [String: String]?
    internal var userPropertiesAnyValue: [String: Any]?
    internal var groups: [String: [String]]?
    internal var groupProperties: [String: [String: [String: Any]]]?

    @discardableResult
    @objc public func userId(_ userId: String?) -> ExperimentUserBuilder {
        self.userId = userId
        return self
    }

    @discardableResult
    @objc public func deviceId(_ deviceId: String?) -> ExperimentUserBuilder {
        self.deviceId = deviceId
        return self
    }

    @discardableResult
    @objc public func country(_ country: String?) -> ExperimentUserBuilder {
        self.country = country
        return self
    }

    @discardableResult
    @objc public func region(_ region: String?) -> ExperimentUserBuilder {
        self.region = region
        return self
    }

    @discardableResult
    @objc public func city(_ city: String?) -> ExperimentUserBuilder {
        self.city = city
        return self
    }

    @discardableResult
    @objc public func language(_ language: String?) -> ExperimentUserBuilder {
        self.language = language
        return self
    }

    @discardableResult
    @objc public func platform(_ platform: String?) -> ExperimentUserBuilder {
        self.platform = platform
        return self
    }

    @discardableResult
    @objc public func version(_ version: String?) -> ExperimentUserBuilder {
        self.version = version
        return self
    }

    @discardableResult
    @objc public func dma(_ dma: String?) -> ExperimentUserBuilder {
        self.dma = dma
        return self
    }

    @discardableResult
    @objc public func os(_ os: String?) -> ExperimentUserBuilder {
        self.os = os
        return self
    }

    @discardableResult
    @objc public func deviceManufacturer(_ deviceManufacturer: String?) -> ExperimentUserBuilder {
        self.deviceManufacturer = deviceManufacturer
        return self
    }

    @discardableResult
    @objc public func deviceModel(_ deviceModel: String?) -> ExperimentUserBuilder {
        self.deviceModel = deviceModel
        return self
    }

    @discardableResult
    @objc public func carrier(_ carrier: String?) -> ExperimentUserBuilder {
        self.carrier = carrier
        return self
    }

    @discardableResult
    @objc public func library(_ library: String?) -> ExperimentUserBuilder {
        self.library = library
        return self
    }

    @discardableResult
    @objc public func userProperties(_ userProperties: [String: Any]?) -> ExperimentUserBuilder {
        guard let userProperties = userProperties else {
            self.userProperties = nil
            self.userPropertiesAnyValue = nil
            return self
        }
        for (k, v) in userProperties {
            _ = self.userProperty(k, value: v)
        }
        return self
    }

    @discardableResult
    @objc public func userProperty(_ property: String, value: Any) -> ExperimentUserBuilder {
        if let stringValue = value as? String {
            if self.userProperties == nil {
                self.userProperties = [property: stringValue]
            } else {
                self.userProperties![property] = stringValue
            }
        }
        if self.userPropertiesAnyValue == nil {
            self.userPropertiesAnyValue = [property: value]
        } else {
            self.userPropertiesAnyValue![property] = value
        }
        return self
    }
    
    @discardableResult
    public func groups(_ groups: [String: [String]]?) -> ExperimentUserBuilder {
        self.groups = groups
        return self
    }

    @discardableResult
    public func group(_ groupType: String, _ groupName: String) -> ExperimentUserBuilder {
        var groups = self.groups ?? [:]
        groups[groupType] = [groupName]
        self.groups = groups
        return self
    }
   
    @discardableResult
    public func groupProperties(_ groupProperties: [String: [String: [String: Any]]]?) -> ExperimentUserBuilder {
        self.groupProperties = groupProperties
        return self
    }
  
    @discardableResult
    public func groupProperty(_ groupType: String, _ groupName: String, _ key: String, _ value: String) -> ExperimentUserBuilder {
        guard self.groupProperties?[groupType] != nil else {
            self.groupProperties = [groupType:[groupName:[key:value]]]
            return self
        }
        guard self.groupProperties?[groupType]?[groupName] != nil else {
            self.groupProperties?[groupType] = [groupName:[key:value]]
            return self
        }
        self.groupProperties?[groupType]?[groupName]?[key] = value
        return self
    }

    @objc public func build() -> ExperimentUser {
        return ExperimentUser(builder: self)
    }
}

internal extension ExperimentUser {

    func toDictionary() -> [String:Any] {
        var data = [String:Any]()
        data["device_id"] = self.deviceId
        data["user_id"] = self.userId
        data["version"] = self.version
        data["country"] = self.country
        data["region"] = self.region
        data["dma"] = self.dma
        data["city"] = self.city
        data["language"] = self.language
        data["platform"] = self.platform
        data["os"] = self.os
        data["device_manufacturer"] = self.deviceManufacturer
        data["device_model"] = self.deviceModel
        data["carrier"] = self.carrier
        data["library"] = self.library
        
        // Convert NSDate objects to ISO 8601 strings in user_properties
        if let userProperties = self.userPropertiesAnyValue {
            var convertedUserProperties = [String:Any]()
            for (key, value) in userProperties {
                if let dateValue = value as? Date {
                    convertedUserProperties[key] = dateValue.iso8601
                } else {
                    convertedUserProperties[key] = value
                }
            }
            data["user_properties"] = convertedUserProperties
        }
        
        // Convert NSDate objects to ISO 8601 strings in group_properties
        if let groupProperties = self.groupProperties {
            var convertedGroupProperties = [String:Any]()
            for (groupType, groups) in groupProperties {
                var convertedGroups = [String:Any]()
                for (groupName, properties) in groups {
                    var convertedProperties = [String:Any]()
                    for (key, value) in properties {
                        if let dateValue = value as? Date {
                            convertedProperties[key] = dateValue.iso8601
                        } else {
                            convertedProperties[key] = value
                        }
                    }
                    convertedGroups[groupName] = convertedProperties
                }
                convertedGroupProperties[groupType] = convertedGroups
            }
            data["group_properties"] = convertedGroupProperties
        }
        
        return data
    }
    
    func merge(_ user: ExperimentUser?) -> ExperimentUser {
        let mergedUserProperties = takeOrMerge(self.getUserProperties(), user?.getUserProperties()) { t, o in
            return t.merging(o) { (new, _) in new }
        }
        return self.copyToBuilder()
            .deviceId(takeOrMerge(self.deviceId, user?.deviceId))
            .userId(takeOrMerge(self.userId, user?.userId))
            .version(takeOrMerge(self.version, user?.version))
            .country(takeOrMerge(self.country, user?.country))
            .region(takeOrMerge(self.region, user?.region))
            .dma(takeOrMerge(self.dma, user?.dma))
            .city(takeOrMerge(self.city, user?.city))
            .language(takeOrMerge(self.language, user?.language))
            .platform(takeOrMerge(self.platform, user?.platform))
            .os(takeOrMerge(self.os, user?.os))
            .deviceManufacturer(takeOrMerge(self.deviceManufacturer, user?.deviceManufacturer))
            .deviceModel(takeOrMerge(self.deviceModel, user?.deviceModel))
            .carrier(takeOrMerge(self.carrier, user?.carrier))
            .library(takeOrMerge(self.library, user?.library))
            .userProperties(mergedUserProperties)
            // TODO: once groups are passed through integration, actually merge all groups.
            .groups(takeOrMerge(self.groups, user?.groups))
            // TODO: once groups are passed through integration, actually merge all group properties.
            .groupProperties(takeOrMerge(self.groupProperties, user?.groupProperties))
            .build()
    }
}

private func takeOrMerge<T>(_ this: T?, _ other: T?, _ merger: ((T, T) -> T)? = nil) -> T? {
    if this == nil {
        return other
    } else if other == nil {
        return this
    } else if merger != nil {
        return merger!(this!, other!)
    } else {
        return this
    }
}

extension ExperimentUser {
    func toEvaluationContext() -> [String: Any?] {
        var user = toDictionary()
        user.removeValue(forKey: "groups")
        user.removeValue(forKey: "group_properties")
        var context: [String: Any?] = ["user": user]
        // Re-configured group properties to match expected context format.
        if let userGroups = groups {
            var groups: [String: [String: Any]] = [:]
            for (groupType, groupNames) in userGroups {
                if let groupName = groupNames.first {
                    var groupNameMap: [String: Any] = ["group_name": groupName]
                    // Check for group properties
                    if let groupProperties = groupProperties?[groupType]?[groupName] ?? nil {
                        groupNameMap["group_properties"] = groupProperties
                    }
                    groups[groupType] = groupNameMap
                }
            }
            context["groups"] = groups
        }
        return context
    }
}

internal extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
}

internal extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
