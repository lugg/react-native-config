#!/usr/bin/env ruby

require "json"

# find the project dotenv file above node_modules/react-native-config/ios/
dotenv = File.read(File.join(Dir.pwd, "../../../.env")).split("\n").inject({}) do |h, line|
  key, val = line.split("=", 2)
  h.merge!(key => val)
end

puts ENV.inspect

# dump as json
path = File.join(ENV["TARGET_TEMP_DIR"], "dotenv.json")
File.open(path, "w") { |f| f.puts dotenv.to_json }

puts "Wrote to #{path}"
