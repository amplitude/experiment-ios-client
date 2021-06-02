//
//  ExperimentUser.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public struct ExperimentUser: Equatable {

    public private(set) var deviceId: String?
    public private(set) var userId: String?
    public private(set) var version: String?
    public private(set) var country: String?
    public private(set) var region: String?
    public private(set) var dma: String?
    public private(set) var city: String?
    public private(set) var language: String?
    public private(set) var platform: String?
    public private(set) var os: String?
    public private(set) var deviceManufacturer: String?
    public private(set) var deviceModel: String?
    public private(set) var carrier: String?
    public private(set) var library: String?
    public private(set) var userProperties: [String: String]?
    
    public func copyToBuilder() -> Builder {
        return Builder()
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

    public class Builder {

        private var user = ExperimentUser()

        public func userId(_ userId: String?) -> Builder {
            self.user.userId = userId
            return self
        }

        public func deviceId(_ deviceId: String?) -> Builder {
            self.user.deviceId = deviceId
            return self
        }

        public func country(_ country: String?) -> Builder {
            self.user.country = country
            return self
        }

        public func region(_ region: String?) -> Builder {
            self.user.region = region
            return self
        }

        public func city(_ city: String?) -> Builder {
            self.user.city = city
            return self
        }

        public func language(_ language: String?) -> Builder {
            self.user.language = language
            return self
        }

        public func platform(_ platform: String?) -> Builder {
            self.user.platform = platform
            return self
        }

        public func version(_ version: String?) -> Builder {
            self.user.version = version
            return self
        }

        public func dma(_ dma: String?) -> Builder {
            self.user.dma = dma
            return self
        }

        public func os(_ os: String?) -> Builder {
            self.user.os = os
            return self
        }

        public func deviceManufacturer(_ deviceManufacturer: String?) -> Builder {
            self.user.deviceManufacturer = deviceManufacturer
            return self
        }

        public func deviceModel(_ deviceModel: String?) -> Builder {
            self.user.deviceModel = deviceModel
            return self
        }

        public func carrier(_ carrier: String?) -> Builder {
            self.user.carrier = carrier
            return self
        }

        public func library(_ library: String?) -> Builder {
            self.user.library = library
            return self
        }

        public func userProperties(_ userProperties: [String: String]?) -> Builder {
            self.user.userProperties = userProperties
            return self
        }

        public func userProperty(_ property: String, value: String) -> Builder {
            guard var userProperties = user.userProperties else {
                self.user.userProperties = [property: value]
                return self
            }
            userProperties[property] = value
            return self
        }

        public func build() -> ExperimentUser {
            return user
        }
    }

    internal func toDictionary() -> [String:Any] {
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
}

internal extension ExperimentUser {
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
