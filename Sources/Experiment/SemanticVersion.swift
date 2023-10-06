//
//  SemanticVersion.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal struct SemanticVersion: Comparable {
    
    private static let MAJOR_MINOR_REGEX = "(\\d+)\\.(\\d+)"
    private static let PATCH_REGEX = "(\\d+)"
    private static let PRERELEASE_REGEX = "(-(([-\\w]+\\.?)*))?"
    private static let VERSION_PATTERN = "^\(MAJOR_MINOR_REGEX)(\\.\(PATCH_REGEX)\(PRERELEASE_REGEX))?$"
    
    let major: Int
    let minor: Int
    let patch: Int
    let preRelease: String?
    
    static func parse(version: String?) -> SemanticVersion? {
        guard let version = version else {
            return nil
        }
        guard let regex = try? NSRegularExpression(pattern: VERSION_PATTERN) else {
            return nil
        }
        let matches = regex.matches(in: version, range: NSRange(0..<version.count))
        guard let match = matches.first else {
            return nil
        }
        var captureGroups: [String?] = []
        for rangeIndex in 0..<match.numberOfRanges {
            let matchRange = match.range(at: rangeIndex)
            if let substringRange = Range(matchRange, in: version) {
                captureGroups.append(String(version[substringRange]))
            } else {
                captureGroups.append(nil)
            }
        }
        guard let major = Int(string: captureGroups[1]), let minor = Int(string: captureGroups[2]) else {
            return nil
        }
        let patch = Int(string: captureGroups[4]) ?? 0
        let preRelease = captureGroups[5]
        return SemanticVersion(major: major, minor: minor, patch: patch, preRelease: preRelease)
    }
    
    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major > rhs.major {
            return false
        } else if lhs.minor < rhs.minor {
            return true
        } else if lhs.minor > rhs.minor {
            return false
        } else if lhs.patch < rhs.patch {
            return true
        } else if lhs.patch > rhs.patch {
            return false
        } else if lhs.preRelease != nil && rhs.preRelease == nil {
            return true
        } else if lhs.preRelease == nil && rhs.preRelease != nil {
            return false
        } else if let lhsPreRelease = lhs.preRelease, let rhsPreRelease = rhs.preRelease {
            return lhsPreRelease < rhsPreRelease
        } else {
            return false
        }
    }
}

private extension Int {
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        self.init(string)
    }
}
