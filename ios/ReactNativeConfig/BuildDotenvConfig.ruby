#!/usr/bin/env ruby

require "json"

# defaults
file = ".env"
custom_env = false

# pick a custom env file if set
if File.exists?("/tmp/envfile")
  custom_env = true
  file = File.read("/tmp/envfile").strip
end

puts "Reading env from #{file}"

# find that above node_modules/react-native-config/ios/
dotenv = File.read(File.join(Dir.pwd, "../../../#{file}")).split("\n").inject({}) do |h, line|
  key, val = line.split("=", 2)
  h.merge!(key => val)
end

# create obj file that sets DOT_ENV as a NSDictionary
dotenv_objc = dotenv.map { |k, v| %Q(@"#{k}":@"#{v}") }.join(",")
template = <<EOF
  #define DOT_ENV @{ #{dotenv_objc} };
EOF

# write it so that ReactNativeConfig.m can return it
path = File.join(ENV["SYMROOT"], "GeneratedDotEnv.m")
File.open(path, "w") { |f| f.puts template }

if custom_env
  File.delete("/tmp/envfile")
end

puts "Wrote to #{path}"