#!/usr/bin/env ruby

require "json"

# pick a custom env file if set
if File.exists?("/tmp/envfile")
  custom_env = true
  file = File.read("/tmp/envfile").strip
else
  custom_env = false
  file = ".env"
end

puts "Reading env from #{file}"

dotenv = begin
  # https://regex101.com/r/aFZMSB
  dotenv_pattern = /^(?:export\s+|)(?<key>[[:alnum:]_]+)=((?<quote>["'])?(?<val>.*?[^\\])\k<quote>?|)$/
  # find that above node_modules/react-native-config/ios/
  raw = File.read(File.join(Dir.pwd, "../../../#{file}"))
  raw.split("\n").inject({}) do |h, line|
    m = line.match(dotenv_pattern)
    next h if m.nil?
    key = m[:key]
    # Ensure string (in case of empty value) and escape any quotes present in the value.
    val = m[:val].to_s.gsub('"', '\"')
    h.merge(key => val)
  end
rescue Errno::ENOENT
  puts("**************************")
  puts("*** Missing .env file ****")
  puts("**************************")
  {} # set dotenv as an empty hash
end

# create obj file that sets DOT_ENV as a NSDictionary
dotenv_objc = dotenv.map { |k, v| %Q(@"#{k}":@"#{v}") }.join(",")
template = <<EOF
  #define DOT_ENV @{ #{dotenv_objc} };
EOF

# write it so that ReactNativeConfig.m can return it
path = File.join(ENV["SYMROOT"], "GeneratedDotEnv.m")
File.open(path, "w") { |f| f.puts template }

# create header file with defines for the Info.plist preprocessor
info_plist_defines_objc = dotenv.map { |k, v| %Q(#define __RN_CONFIG_#{k}  #{v}) }.join("\n")

# write it so the Info.plist preprocessor can access it
path = File.join(ENV["BUILD_DIR"], "GeneratedInfoPlistDotEnv.h")
File.open(path, "w") { |f| f.puts info_plist_defines_objc }

if custom_env
  File.delete("/tmp/envfile")
end

puts "Wrote to #{path}"
