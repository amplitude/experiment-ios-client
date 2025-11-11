//
//  LoggerTests.swift
//  ExperimentTests
//
//  Tests for AmpLogger log level filtering and configuration
//

import AmplitudeCore
import XCTest
@testable import Experiment

class MockCoreLogger: CoreLogger {
    var errorMessages: [String] = []
    var warnMessages: [String] = []
    var logMessages: [String] = []
    var debugMessages: [String] = []

    func error(message: String) {
        errorMessages.append(message)
    }

    func warn(message: String) {
        warnMessages.append(message)
    }

    func log(message: String) {
        logMessages.append(message)
    }

    func debug(message: String) {
        debugMessages.append(message)
    }
}

class LoggerTests: XCTestCase {

    // MARK: - Test Helpers

    private func logAllLevels(_ logger: CoreLogger) {
        logger.error(message: "Test error")
        logger.warn(message: "Test warn")
        logger.log(message: "Test log")
        logger.debug(message: "Test debug")
    }

    private func assertMessageCounts(_ logger: MockCoreLogger,
                                     error: Int, warn: Int, log: Int, debug: Int,
                                     file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(logger.errorMessages.count, error, file: file, line: line)
        XCTAssertEqual(logger.warnMessages.count, warn, file: file, line: line)
        XCTAssertEqual(logger.logMessages.count, log, file: file, line: line)
        XCTAssertEqual(logger.debugMessages.count, debug, file: file, line: line)
    }

    // MARK: - AmpLogger Log Level Filtering Tests

    func testAmpLoggerLogLevelOff() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(logLevel: .off, loggerProvier: mockLogger)

        logAllLevels(ampLogger)
        assertMessageCounts(mockLogger, error: 0, warn: 0, log: 0, debug: 0)
    }

    func testAmpLoggerLogLevelError() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(logLevel: .error, loggerProvier: mockLogger)

        logAllLevels(ampLogger)
        assertMessageCounts(mockLogger, error: 1, warn: 0, log: 0, debug: 0)
        XCTAssertEqual(mockLogger.errorMessages[0], "Test error")
    }

    func testAmpLoggerLogLevelWarn() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(logLevel: .warn, loggerProvier: mockLogger)

        logAllLevels(ampLogger)
        assertMessageCounts(mockLogger, error: 1, warn: 1, log: 0, debug: 0)
    }

    func testAmpLoggerLogLevelLog() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(logLevel: .log, loggerProvier: mockLogger)

        logAllLevels(ampLogger)
        assertMessageCounts(mockLogger, error: 1, warn: 1, log: 1, debug: 0)
    }

    func testAmpLoggerLogLevelDebug() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(logLevel: .debug, loggerProvier: mockLogger)

        logAllLevels(ampLogger)
        assertMessageCounts(mockLogger, error: 1, warn: 1, log: 1, debug: 1)
    }

    func testAmpLoggerDefaultLogLevel() {
        let mockLogger = MockCoreLogger()
        let ampLogger = AmpLogger(loggerProvier: mockLogger)

        XCTAssertEqual(ampLogger.logLevel, .warn)
    }

    // MARK: - ExperimentConfig Tests

    func testExperimentConfigDefaultLogger() {
        let config = ExperimentConfig()

        XCTAssertEqual(config.logger.logLevel, .warn)
        XCTAssertTrue(config.logger.loggerProvider is DefaultLogger)
    }

    // MARK: - ExperimentConfigBuilder Tests

    func testExperimentConfigBuilderDefaultLogger() {
        let config = ExperimentConfigBuilder()
            .build()

        XCTAssertEqual(config.logger.logLevel, .warn)
        XCTAssertTrue(config.logger.loggerProvider is DefaultLogger)
    }

    func testExperimentConfigBuilderSetLogLevel() {
        let config = ExperimentConfigBuilder()
            .logLevel(.log)
            .build()

        XCTAssertEqual(config.logger.logLevel, .log)
    }

    func testExperimentConfigBuilderSetDebug() {
        let config = ExperimentConfigBuilder()
            .debug(true)
            .build()

        XCTAssertEqual(config.debug, true)
        XCTAssertEqual(config.logger.logLevel, .debug)
    }

    func testExperimentConfigBuilderWithCustomLogger() {
        let customLogger = MockCoreLogger()
        let config = ExperimentConfigBuilder()
            .loggerProvider(customLogger)
            .build()

        XCTAssertTrue(config.logger.loggerProvider is MockCoreLogger)
    }

    func testExperimentConfigBuilderLogLevelWithCustomLogger() {
        let customLogger = MockCoreLogger()
        let config = ExperimentConfigBuilder()
            .loggerProvider(customLogger)
            .logLevel(.debug)
            .build()

        XCTAssertEqual(config.logger.logLevel, .debug)
        XCTAssertTrue(config.logger.loggerProvider is MockCoreLogger)
    }

    func testExperimentConfigBuilderDebugOverridesLogLevel() {
        let config = ExperimentConfigBuilder()
            .logLevel(.error)
            .debug(true)
            .build()

        XCTAssertEqual(config.logger.logLevel, .debug)
    }

    func testExperimentConfigBuilderLogLevelAfterDebug() {
        let config = ExperimentConfigBuilder()
            .debug(true)
            .logLevel(.warn)
            .build()

        XCTAssertEqual(config.logger.logLevel, .warn)
    }

}
