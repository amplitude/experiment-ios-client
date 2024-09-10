experiment_version = "1.13.6" # Version is managed automatically by semantic-release, please dont change it manually

Pod::Spec.new do |spec|

  spec.name         = "AmplitudeExperiment"
  spec.version      = experiment_version 
  spec.summary      = "Amplitude Experiment SDK"
  spec.license      = { :type => "MIT" }
  spec.author       = { "Amplitude" => "experiment@amplitude.com" }
  spec.homepage     = "https://amplitude.com"
  spec.source       = { :git => "https://github.com/amplitude/experiment-ios-client.git", :tag => "v#{spec.version}" }

  spec.swift_version = '5.0'
  
  spec.ios.deployment_target  = '10.0'
  spec.ios.source_files       = 'Sources/Experiment/**/*.{h,swift}'
  spec.ios.resource_bundle    = { 'AmplitudeExperiment': ['Sources/Experiment/PrivacyInfo.xcprivacy'] }

  spec.osx.deployment_target  = '10.13'
  spec.osx.source_files       = 'sources/Experiment/**/*.{h,swift}'
  spec.osx.resource_bundle    = { 'AmplitudeExperiment': ['Sources/Experiment/PrivacyInfo.xcprivacy'] }

  spec.tvos.deployment_target = '10.0'
  spec.tvos.source_files      = 'sources/Experiment/**/*.{h,swift}'
  spec.tvos.resource_bundle   = { 'AmplitudeExperiment': ['Sources/Experiment/PrivacyInfo.xcprivacy'] }
  
  spec.watchos.deployment_target = '3.0'
  spec.watchos.source_files      = 'sources/Experiment/**/*.{h,swift}'
  spec.watchos.resource_bundle   = { 'AmplitudeExperiment': ['Sources/Experiment/PrivacyInfo.xcprivacy'] }
  
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  spec.dependency 'AnalyticsConnector', '~> 1.0'

end
