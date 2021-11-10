module.exports = {
  "branches": ["main"],
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "angular",
      "parserOpts": {
        "noteKeywords": ["BREAKING CHANGE", "BREAKING CHANGES", "BREAKING"]
      }
    }],
    ["@semantic-release/release-notes-generator", {
      "preset": "angular",
    }],
    ["@semantic-release/changelog", {
      "changelogFile": "CHANGELOG.md"
    }],
    "@semantic-release/github",
    [
      "@google/semantic-release-replace-plugin",
      {
        "replacements": [
          {
            "files": ["AmplitudeExperiment.podspec"],
            "from": "experiment_version = \".*\"",
            "to": "experiment_version = \"${nextRelease.version}\"",
            "results": [
              {
                "file": "AmplitudeExperiment.podspec",
                "hasChanged": true,
                "numMatches": 1,
                "numReplacements": 1
              }
            ],
            "countMatches": true
          },
          {
            "files": ["Sources/Experiment/ExperimentConfig.swift"],
            "from": "Version: String = \".*\"",
            "to": "Version: String = \"${nextRelease.version}\"",
            "results": [
              {
                "file": "Sources/Experiment/ExperimentConfig.swift",
                "hasChanged": true,
                "numMatches": 1,
                "numReplacements": 1
              }
            ],
            "countMatches": true
          },
        ]
      }
    ],
    ["@semantic-release/git", {
      "assets": ["AmplitudeExperiment.podspec", "Sources/Experiment/ExperimentConfig.swift", "CHANGELOG.md", "docs/*"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }],
    ["@semantic-release/exec", {
      "publishCmd": "pod trunk push AmplitudeExperiment.podspec --allow-warnings",
    }],
  ],
}
