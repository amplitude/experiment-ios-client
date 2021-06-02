//
//  ContextProvider.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

public protocol ExperimentUserProvider {
    func getUser() -> ExperimentUser
}
