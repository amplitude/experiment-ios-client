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
 *
 * ```
 * {
 *   "event_type": "$exposure",
 *   "event_properties": {
 *     "flag_key": "<flagKey>",
 *     "variant": "<variant>",
 *     "experiment_key": "<expKey>"
 *   }
 * }
 * ```
 *
 * Where `<flagKey>`, `<variant>` and `<expKey>` are the `flagKey`,
 * `variant`, and `experimentKey` members on this class.
 *
 * For example, if you're using Segment for analytics:
 *
 * ```
 * analytics.track(name: "$exposure", properties: [
 *   "flag_key": exposure.flagKey,
 *   "variant": exposure.variant,
 *   "experiment_key": exposure.experimentKey
 * ])
 * ```
 */
@objc public final class Exposure : NSObject, Sendable {
    /**
     * (Required) The key for the flag the user was exposed to.
     */
    @objc public let flagKey: String
    /**
     * (Optional) The variant the user was exposed to. If null or missing, the
     * event will not be persisted, and will unset the user property.
     */
    @objc public let variant: String?
    /**
     * (Optional) The experiment key used to differentiate between multiple
     * experiments associated with the same flag.
     */
    @objc public let experimentKey: String?
    /**
     * (Optional) Flag, segment, and variant metadata produced as a result of
     * evaluation for the user. Used for system purposes.
     */
    @objc public let metadata: [String: (any Sendable)]?

    internal init(flagKey: String, variant: String?, experimentKey: String?, metadata: [String: (any Sendable)?]?) {
        self.flagKey = flagKey
        self.variant = variant
        self.experimentKey = experimentKey
        if let m = metadata {
            self.metadata = m.compactMapValues { $0 }
        } else {
            self.metadata = nil
        }
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Exposure else {
            return false
        }
        return self.flagKey == other.flagKey && self.variant == other.variant && self.experimentKey == other.experimentKey
    }
}
