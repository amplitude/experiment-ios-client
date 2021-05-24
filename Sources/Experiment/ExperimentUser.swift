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
    public private(set) var deviceFamily: String?
    public private(set) var deviceType: String?
    public private(set) var deviceManufacturer: String?
    public private(set) var deviceModel: String?
    public private(set) var carrier: String?
    public private(set) var library: String?
    public private(set) var userProperties: [String: String]?

    public class Builder {

        private var user = ExperimentUser()

        public func setUserId(_ userId: String?) -> Builder {
            self.user.userId = userId
            return self
        }

        public func setDeviceId(_ deviceId: String?) -> Builder {
            self.user.deviceId = deviceId
            return self
        }

        public func setCountry(_ country: String?) -> Builder {
            self.user.country = country
            return self
        }

        public func setRegion(_ region: String?) -> Builder {
            self.user.region = region
            return self
        }

        public func setCity(_ city: String?) -> Builder {
            self.user.city = city
            return self
        }

        public func setLanguage(_ language: String?) -> Builder {
            self.user.language = language
            return self
        }

        public func setPlatform(_ platform: String?) -> Builder {
            self.user.platform = platform
            return self
        }

        public func setVersion(_ version: String?) -> Builder {
            self.user.version = version
            return self
        }

        public func setDma(_ dma: String?) -> Builder {
            self.user.dma = dma
            return self
        }

        public func setOs(_ os: String?) -> Builder {
            self.user.os = os
            return self
        }

        public func setDeviceFamily(_ deviceFamily: String?) -> Builder {
            self.user.deviceFamily = deviceFamily
            return self
        }

        public func setDeviceType(_ deviceType: String?) -> Builder {
            self.user.deviceType = deviceType
            return self
        }

        public func setDeviceManufacturer(_ deviceManufacturer: String?) -> Builder {
            self.user.deviceManufacturer = deviceManufacturer
            return self
        }

        public func setDeviceModel(_ deviceModel: String?) -> Builder {
            self.user.deviceModel = deviceModel
            return self
        }

        public func setCarrier(_ carrier: String?) -> Builder {
            self.user.carrier = carrier
            return self
        }

        public func setLibrary(_ library: String?) -> Builder {
            self.user.library = library
            return self
        }

        public func setUserProperties(_ userProperties: [String: String]?) -> Builder {
            self.user.userProperties = userProperties
            return self
        }

        public func setUserProperty(_ property: String, value: String) -> Builder {
            guard var userProperties = user.userProperties else {
                self.user.userProperties = [property: value]
                return self
            }
            userProperties[property] = value
            return self
        }

        public func copyUser(_ user: ExperimentUser) -> Builder {
            if let userId = user.userId {
                self.user.userId = userId
            }
            if let deviceId = user.deviceId {
                self.user.deviceId = deviceId
            }
            if let country = user.country {
                self.user.country = country
            }
            if let region = user.region {
                self.user.region = region
            }
            if let city = user.city {
                self.user.city = city
            }
            if let language = user.language {
                self.user.language = language
            }
            if let platform = user.platform {
                self.user.platform = platform
            }
            if let version = user.version {
                self.user.version = version
            }
            if let os = user.os {
                self.user.os = os
            }
            if let dma = user.dma {
                self.user.dma = dma
            }
            if let deviceFamily = user.deviceFamily {
                self.user.deviceFamily = deviceFamily
            }
            if let deviceType = user.deviceType {
                self.user.deviceType = deviceType
            }
            if let deviceManufacturer = user.deviceManufacturer {
                self.user.deviceManufacturer = deviceManufacturer
            }
            if let deviceModel = user.deviceModel {
                self.user.deviceModel = deviceModel
            }
            if let carrier = user.carrier {
                self.user.carrier = carrier
            }
            if let library = user.library {
                self.user.library = library
            }
            if let userProperties = user.userProperties {
                self.user.userProperties = userProperties
            }
            return self
        }

        public func build() -> ExperimentUser {
            return user
        }
    }

    public func toDictionary() -> [String:Any] {
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
        data["device_family"] = self.deviceFamily
        data["device_type"] = self.deviceType
        data["device_manufacturer"] = self.deviceManufacturer
        data["device_model"] = self.deviceModel
        data["carrier"] = self.carrier
        data["library"] = self.library
        data["user_properties"] = self.userProperties
        return data
    }
}
