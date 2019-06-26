# frozen_string_literal: true

require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-config'
  s.version      = package['version']
  s.summary      = 'Expose config variables to React Native apps'
  s.author       = 'Pedro Belo'

  s.homepage     = 'https://github.com/luggit/react-native-config'

  s.license      = 'MIT'
  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'

  s.source       = { git: 'https://github.com/luggit/react-native-config.git', tag: s.version.to_s }
  s.script_phase = {
    name: 'Config codegen',
    script: %(
set -ex
HOST_PATH="$SRCROOT/../.."
"${PODS_TARGET_SRCROOT}/ios/ReactNativeConfig/BuildDotenvConfig.rb" "$HOST_PATH" "${PODS_TARGET_SRCROOT}/ios/ReactNativeConfig"
),
    execution_position: :before_compile,
    input_files: ['$(SRCROOT)/ReactNativeConfig/BuildDotenvConfig.rb']
  }

  s.source_files = 'ios/**/*.{h,m}'
  s.requires_arc = true

  s.dependency 'React'
end
