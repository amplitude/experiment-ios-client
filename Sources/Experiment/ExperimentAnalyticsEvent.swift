//
//  ExperimentAnalyticsEvent.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

public protocol ExperimentAnalyticsEvent {
    var name: String { get }
    var properties: [String: String?] { get }
}
