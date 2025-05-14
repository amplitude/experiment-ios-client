//
//  ExperimentPluginTests.swift
//  Experiment
//
//  Created by Chris Leonavicius on 5/9/25.
//

import AmplitudeCore
@testable import Experiment
import XCTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class ExperimentPluginTests: XCTestCase {

    let apiKey = "test_key"
    let apiKey2 = "test_key2"
    let deploymentKey = "deplyoment_key"
    let analytics = MockAnalyticsClient()
    lazy var experiment = Experiment.initialize(apiKey: apiKey, config: .init())
    lazy var experiment2 = Experiment.initialize(apiKey: apiKey2, config: .init())
    lazy var context = AmplitudeContext(apiKey: apiKey, instanceName: "instance")
    lazy var context2 = AmplitudeContext(apiKey: apiKey, instanceName: "instance2")

    func testExternalClientSetup() {
        let experimentPlugin = ExperimentPlugin(experiment: experiment)

        XCTAssertIdentical(experimentPlugin.experiment, experiment)

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)

        XCTAssertIdentical(experimentPlugin.experiment, experiment)
    }

    func testExternalClientPluginLookup() {
        let experimentPlugin = ExperimentPlugin(experiment: experiment)

        let pluginHost = MockPluginHost()
        pluginHost.add(plugin: experimentPlugin)

        XCTAssertIdentical(pluginHost.experiment, experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: apiKey), experiment)

        let experimentPlugin2 = ExperimentPlugin(experiment: experiment2)
        pluginHost.add(plugin: experimentPlugin2)

        XCTAssertNil(pluginHost.experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: apiKey2), experiment2)

        XCTAssert(pluginHost.has(plugin: experimentPlugin))
        XCTAssert(pluginHost.has(plugin: experimentPlugin2))
    }

    func testHostedClientDeploymentKeySetup() {
        let experimentPlugin = ExperimentPlugin(config: .init(deploymentKey: deploymentKey))

        XCTAssertNil(experimentPlugin.experiment)

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)
        let experiment = experimentPlugin.experiment as? DefaultExperimentClient

        XCTAssertNotNil(experiment)
        XCTAssertEqual(experiment?.apiKey, deploymentKey)

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)

        XCTAssertNotNil(experimentPlugin.experiment)
        XCTAssertIdentical(experiment, experimentPlugin.experiment)
        XCTAssertEqual(experiment?.apiKey, deploymentKey)
    }

    func testHostedClientDeploymentKeyPluginLookup() {
        let experimentPlugin = ExperimentPlugin(config: .init(deploymentKey: deploymentKey))
        let pluginHost = MockPluginHost()
        pluginHost.add(plugin: experimentPlugin)

        XCTAssertNil(pluginHost.experiment)
        XCTAssertNil(pluginHost.experiment(apiKey: deploymentKey))

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)
        let experiment = pluginHost.experiment as? DefaultExperimentClient

        XCTAssertNotNil(experiment)
        XCTAssertEqual(experiment?.apiKey, deploymentKey)
        XCTAssertIdentical(pluginHost.experiment(apiKey: deploymentKey), experiment)

        // experimentPlugin2 should not be added as its api key should conflict
        let experimentPlugin2 = ExperimentPlugin(config: .init(deploymentKey: deploymentKey))
        pluginHost.add(plugin: experimentPlugin2)

        XCTAssertIdentical(pluginHost.experiment, experiment)
        XCTAssert(pluginHost.has(plugin: experimentPlugin))
        XCTAssertFalse(pluginHost.has(plugin: experimentPlugin2))

        // experimentPlugin3 should be added as its api key is unique
        let experimentPlugin3 = ExperimentPlugin(experiment: experiment2)
        pluginHost.add(plugin: experimentPlugin3)

        XCTAssert(pluginHost.has(plugin: experimentPlugin))
        XCTAssert(pluginHost.has(plugin: experimentPlugin3))
        XCTAssertNil(pluginHost.experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: deploymentKey), experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: apiKey2), experiment2)
    }

    func testHostedClientApiKeySetup() {
        let experimentPlugin = ExperimentPlugin(config: .init())

        XCTAssertNil(experimentPlugin.experiment)

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)
        let experiment = experimentPlugin.experiment as? DefaultExperimentClient

        XCTAssertNotNil(experiment)
        XCTAssertEqual(experiment?.apiKey, apiKey)

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context2)

        XCTAssertNotNil(experimentPlugin.experiment)
        XCTAssertNotIdentical(experiment, experimentPlugin.experiment)
        XCTAssertEqual(experiment?.apiKey, apiKey)
    }

    func testHostedClientApiKeyPluginLookup() {
        let experimentPlugin = ExperimentPlugin(config: .init())
        let pluginHost = MockPluginHost()
        pluginHost.add(plugin: experimentPlugin)

        XCTAssertNil(pluginHost.experiment)
        XCTAssertNil(pluginHost.experiment(apiKey: apiKey))

        experimentPlugin.setup(analyticsClient: analytics, amplitudeContext: context)
        let experiment = pluginHost.experiment as? DefaultExperimentClient

        XCTAssertNotNil(experiment)
        XCTAssertEqual(experiment?.apiKey, apiKey)
        XCTAssertNil(pluginHost.experiment(apiKey: apiKey))
        XCTAssertIdentical(pluginHost.experiment(apiKey: nil), experiment)

        // experimentPlugin2 should not be added as its api key should conflict
        let experimentPlugin2 = ExperimentPlugin(config: .init())
        pluginHost.add(plugin: experimentPlugin2)

        XCTAssertIdentical(pluginHost.experiment, experiment)
        XCTAssert(pluginHost.has(plugin: experimentPlugin))
        XCTAssertFalse(pluginHost.has(plugin: experimentPlugin2))

        // experimentPlugin3 should be added as its api key is unique
        let experimentPlugin3 = ExperimentPlugin(experiment: experiment2)
        pluginHost.add(plugin: experimentPlugin3)

        XCTAssert(pluginHost.has(plugin: experimentPlugin))
        XCTAssert(pluginHost.has(plugin: experimentPlugin3))
        XCTAssertNil(pluginHost.experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: nil), experiment)
        XCTAssertIdentical(pluginHost.experiment(apiKey: apiKey2), experiment2)
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class MockPluginHost: PluginHost {

    private var plugins: [UniversalPlugin] = []

    func add(plugin: UniversalPlugin) {
        if let name = plugin.name, self.plugin(name: name) != nil {
            return
        }
        plugins.append(plugin)
    }

    func has(plugin: UniversalPlugin) -> Bool {
        return plugins.contains { $0 === plugin }
    }

    func plugin(name: String) -> (any UniversalPlugin)? {
        return plugins.first { $0.name == name }
    }

    func plugins<PluginType: UniversalPlugin>(type: PluginType.Type) -> [PluginType] {
        var plugins: [PluginType] = []

        self.plugins.forEach {
            if let plugin = $0 as? PluginType {
                plugins.append(plugin)
            }
        }

        return plugins
    }
}

struct MockIdentity: AnalyticsIdentity {

    var deviceId: String? = nil
    var userId: String? = nil
    var userProperties: [String : Any] = [:]
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class MockAnalyticsClient: AnalyticsClient {

    var identity: MockIdentity
    var sessionId: Int64
    var optOut: Bool

    init(identity: MockIdentity = MockIdentity(), sessionId: Int64 = -1, optOut: Bool = false) {
        self.identity = identity
        self.sessionId = sessionId
        self.optOut = optOut
    }

    func track(eventType: String, eventProperties: [String: Any]?) {

    }
}
