skylab_version = "1.1.0" # Version is managed automatically by semantic-release, please dont change it manually

Pod::Spec.new do |spec|

  spec.name         = "AmplitudeSkylab"
  spec.version      = skylab_version 
  spec.summary      = "Skylab SDK"
  spec.license      = { :type => "MIT" }
  spec.author       = { "Amplitude" => "skylab@amplitude.com" }
  spec.homepage     = "https://amplitude.com"
  spec.source       = { :git => "https://github.com/amplitude/skylab-ios-client.git", :tag => "v#{spec.version}" }

  spec.swift_version = '5.0'
  
  spec.ios.deployment_target  = '10.0'
  spec.ios.source_files       = 'Sources/Skylab/**/*.{h,swift}'

  spec.osx.deployment_target  = '10.10'
  spec.osx.source_files       = 'sources/skylab/**/*.{h,swift}'

  spec.tvos.deployment_target = '9.0'
  spec.tvos.source_files      = 'sources/skylab/**/*.{h,swift}'
  
  spec.watchos.deployment_target = '3.0'
  spec.watchos.source_files      = 'sources/skylab/**/*.{h,swift}'

  spec.dependency 'Amplitude'

end
