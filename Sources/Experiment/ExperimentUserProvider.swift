//
//  ExperimentUserProvider.swift
//  Experiment
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

/// Provides a user to an ExperimentClient to be merged without overwriting prior to
/// fetching variants for the user. In otherwords, fields are only sent in the fetch request
/// if the user object passed into fetch or stored by the ExperimentClient does not
/// define those fields.
///
/// This is useful for providing contextual information about the platform, or pulling
/// data which may potentially change without explicitly pass the data into the
/// client on each fetch.
@objc public protocol ExperimentUserProvider : Sendable {
    @objc func getUser() -> ExperimentUser
}
