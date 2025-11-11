//
//  ConsoleLogger.swift
//  Experiment
//
//  Default logger implementation using Apple's OSLog framework.
//

import AmplitudeCore
import Foundation
import os.log

@preconcurrency
public class DefaultLogger: CoreLogger, @unchecked Sendable {

    private var logger: OSLog

    public init() {
        self.logger = OSLog(subsystem: "Experiment", category: "Logging")
    }

    public func error(message: String) {
        os_log("Error: %@", log: logger, type: .error, message)
    }

    public func warn(message: String) {
        os_log("Warn: %@", log: logger, type: .default, message)
    }

    public func log(message: String) {
        os_log("Log: %@", log: logger, type: .info, message)
    }

    public func debug(message: String) {
        os_log("Debug: %@", log: logger, type: .debug, message)
    }
}
