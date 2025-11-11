//
//  AmpLogger.swift
//  Experiment
//
//  Created by Kenneth Yeh on 11/11/25.
//

import Foundation
import AmplitudeCore

@objc
@preconcurrency
public class AmpLogger: NSObject, CoreLogger, @unchecked Sendable {

    public var logLevel: LogLevel
    public var loggerProvider: any CoreLogger

    public init(logLevel: LogLevel = LogLevel.warn, loggerProvier: any CoreLogger) {
        self.logLevel = logLevel
        self.loggerProvider = loggerProvier
    }

    public func error(message: String) {
        if logLevel.rawValue >=  LogLevel.error.rawValue {
            loggerProvider.error(message: message)
        }
    }

    public func warn(message: String) {
        if logLevel.rawValue >=  LogLevel.warn.rawValue {
            loggerProvider.warn(message: message)
        }
    }

    public func log(message: String) {
        if logLevel.rawValue >=  LogLevel.log.rawValue {
            loggerProvider.log(message: message)
        }
    }

    public func debug(message: String) {
        if logLevel.rawValue >=  LogLevel.debug.rawValue {
            loggerProvider.debug(message: message)
        }
    }
}
