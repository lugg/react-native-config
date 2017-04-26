require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-config"
  s.version      = package["version"]
  s.summary      = "Expose config variables to React Native apps"
  s.author       = "Pedro Belo"

  s.homepage     = "https://github.com/luggit/react-native-config"

  s.license      = "MIT"
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/luggit/react-native-config.git", :tag => "#{s.version}" }

  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
end
