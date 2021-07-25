//
//  ExperimentAnalyticsProvider.swift
//  Experiment
//
//  Created by Brian Giori on 7/23/21.
//

import Foundation

public protocol ExperimentAnalyticsProvider {
    func track(_ event: ExperimentAnalyticsEvent)
}
