#!/usr/bin/env ruby

require "json"

# find the project dotenv file above node_modules/react-native-config/ios/
dotenv = File.read(File.join(Dir.pwd, "../../../.env")).split("\n").inject({}) do |h, line|
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

puts "Wrote to #{path}"
