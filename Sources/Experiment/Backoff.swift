//
//  Backoff.swift
//  Experiment
//
//  Created by Brian Giori on 6/23/21.
//

import Foundation

internal class Backoff {

    // Configuration
    private let attempts: Int
    private let min: Int
    private let max: Int
    private let scalar: Float

    // Dispatch
    private let lock = DispatchSemaphore(value: 1)
    private let fetchQueue: DispatchQueue

    // State
    private var started: Bool = false
    private var cancelled: Bool = false
    private var fetchTask: URLSessionTask? = nil

    init(attempts: Int, min: Int, max: Int, scalar: Float, queue: DispatchQueue = DispatchQueue(label: "com.amplitude.experiment.backoff", qos: .default)) {
        self.attempts = attempts
        self.min = min
        self.max = max
        self.scalar = scalar
        self.fetchQueue = queue
    }

    func start(
        function: @escaping ( @escaping (Error?) -> Void) -> URLSessionTask?
    ) {
        lock.wait()
        defer { lock.signal() }
        if started {
            return
        }
        self.backoff(attempt: 0, delay: self.min, function: function)
    }

    func cancel() {
        self.fetchQueue.sync { [weak self] in
            guard let self = self else {
                return
            }
            if !self.cancelled {
                self.fetchTask?.cancel()
                self.cancelled = true
            }
        }
    }

    private func backoff(
        attempt: Int,
        delay: Int,
        function: @escaping ( @escaping (Error?) -> Void) -> URLSessionTask?
    ) {
        fetchQueue.asyncAfter(deadline: .now() + .milliseconds(delay)) { [weak self] in
            guard let self = self else {
                return
            }
            if self.cancelled {
                return
            }
            self.fetchTask = function() { error in
                guard error != nil else {
                    // Success
                    print("[Experiment] Retry success")
                    return
                }
                print("[Experiment] Retry failure")
                // Retry the request function
                let nextAttempt = attempt + 1
                if nextAttempt < self.attempts {
                    let nextDelay = Int(Swift.min(Float(delay) * self.scalar, Float(self.max)))
                    self.backoff(attempt: nextAttempt, delay: nextDelay, function: function);
                }
            }
        }
    }
}
