experiment_version = "1.12.0-beta.1" # Version is managed automatically by semantic-release, please dont change it manually

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

  spec.osx.deployment_target  = '10.13'
  spec.osx.source_files       = 'sources/Experiment/**/*.{h,swift}'

  spec.tvos.deployment_target = '10.0'
  spec.tvos.source_files      = 'sources/Experiment/**/*.{h,swift}'
  
  spec.watchos.deployment_target = '3.0'
  spec.watchos.source_files      = 'sources/Experiment/**/*.{h,swift}'

  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  spec.dependency 'AnalyticsConnector', '~> 1.0'

end
