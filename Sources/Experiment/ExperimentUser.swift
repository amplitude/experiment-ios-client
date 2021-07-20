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
    @objc public let userProperties: [String: String]?
    
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
            .userProperties(self.userProperties)
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ExperimentUser else {
            return false
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
            self.userProperties == other.userProperties
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

    @objc public func userId(_ userId: String?) -> ExperimentUserBuilder {
        self.userId = userId
        return self
    }

    @objc public func deviceId(_ deviceId: String?) -> ExperimentUserBuilder {
        self.deviceId = deviceId
        return self
    }

    @objc public func country(_ country: String?) -> ExperimentUserBuilder {
        self.country = country
        return self
    }

    @objc public func region(_ region: String?) -> ExperimentUserBuilder {
        self.region = region
        return self
    }

    @objc public func city(_ city: String?) -> ExperimentUserBuilder {
        self.city = city
        return self
    }

    @objc public func language(_ language: String?) -> ExperimentUserBuilder {
        self.language = language
        return self
    }

    @objc public func platform(_ platform: String?) -> ExperimentUserBuilder {
        self.platform = platform
        return self
    }

    @objc public func version(_ version: String?) -> ExperimentUserBuilder {
        self.version = version
        return self
    }

    @objc public func dma(_ dma: String?) -> ExperimentUserBuilder {
        self.dma = dma
        return self
    }

    @objc public func os(_ os: String?) -> ExperimentUserBuilder {
        self.os = os
        return self
    }

    @objc public func deviceManufacturer(_ deviceManufacturer: String?) -> ExperimentUserBuilder {
        self.deviceManufacturer = deviceManufacturer
        return self
    }

    @objc public func deviceModel(_ deviceModel: String?) -> ExperimentUserBuilder {
        self.deviceModel = deviceModel
        return self
    }

    @objc public func carrier(_ carrier: String?) -> ExperimentUserBuilder {
        self.carrier = carrier
        return self
    }

    @objc public func library(_ library: String?) -> ExperimentUserBuilder {
        self.library = library
        return self
    }

    @objc public func userProperties(_ userProperties: [String: String]?) -> ExperimentUserBuilder {
        self.userProperties = userProperties
        return self
    }

    @objc public func userProperty(_ property: String, value: String) -> ExperimentUserBuilder {
        guard var userProperties = self.userProperties else {
            self.userProperties = [property: value]
            return self
        }
        userProperties[property] = value
        self.userProperties = userProperties
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
        data["user_properties"] = self.userProperties
        return data
    }
    
    func merge(_ user: ExperimentUser?) -> ExperimentUser {
        return self.copyToBuilder()
            .deviceId(takeOrOverwrite(self.deviceId, user?.deviceId))
            .userId(takeOrOverwrite(self.userId, user?.userId))
            .version(takeOrOverwrite(self.version, user?.version))
            .country(takeOrOverwrite(self.country, user?.country))
            .region(takeOrOverwrite(self.region, user?.region))
            .dma(takeOrOverwrite(self.dma, user?.dma))
            .city(takeOrOverwrite(self.city, user?.city))
            .language(takeOrOverwrite(self.language, user?.language))
            .platform(takeOrOverwrite(self.platform, user?.platform))
            .os(takeOrOverwrite(self.os, user?.os))
            .deviceManufacturer(takeOrOverwrite(self.deviceManufacturer, user?.deviceManufacturer))
            .deviceModel(takeOrOverwrite(self.deviceModel, user?.deviceModel))
            .carrier(takeOrOverwrite(self.carrier, user?.carrier))
            .library(takeOrOverwrite(self.library, user?.library))
            .userProperties(takeOrOverwrite(self.userProperties, user?.userProperties))
            .build()
    }
}

private func takeOrOverwrite<T>(_ take: T?, _ or: T?, overwrite: Bool = false) -> T? {
    if take == nil {
        return or
    } else if or == nil {
        return take
    } else if overwrite {
        return or
    } else {
        return take
    }
}
