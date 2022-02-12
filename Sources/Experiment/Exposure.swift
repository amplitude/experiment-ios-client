//
//  Exposure.swift
//  Experiment
//
//  Created by Brian Giori on 2/11/22.
//

import Foundation

/**
 * Improved exposure event for tracking exposures to Amplitude Experiment.
 *
 * This object contains all the required information to send an `$exposure`
 * event through any SDK or CDP to experiment. The resulting exposure event
 * must follow the following definition:
 * ```
 * {
 *   "event_type": "$exposure",
 *   "event_properties": {
 *     "flag_key": "<flagKey>",
 *     "variant": "<variant>"
 *   }
 * }
 * ```
 *
 * Where `<flagKey>` and `<variant>` are the `flagKey` and `variant` members on
 * this class.
 *
 * For example, if you're using Segment for analytics:
 *
 * ```
 * analytics.track(name: "$exposure", properties: [
 *   "flag_key": exposure.flagKey,
 *   "variant": exposure.variant
 * ])
 * ```
 */
@objc public class Exposure : NSObject {
    
    @objc public let flagKey: String
    @objc public let variant: String?
    
    internal init(flagKey: String, variant: String?) {
        self.flagKey = flagKey
        self.variant = variant
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Exposure else {
            return false
        }
        return self.flagKey == other.flagKey && self.variant == other.variant
    }
}
