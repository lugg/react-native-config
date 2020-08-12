#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'ReadDotEnv'
require 'digest'
require 'securerandom'
require 'set'

envs_root = ARGV[0]
m_output_path = ARGV[1]
puts "reading env file from #{envs_root} and writing .m to #{m_output_path}"

# Allow utf-8 charactor in config value
# For example, APP_NAME=中文字符
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

dotenv, custom_env = read_dot_env(envs_root)
puts "read dotenv #{dotenv}"

# create objc file with obfuscated keys, unobfuscated at runtime.
# Implementation inspired from cocoapods-keys: https://github.com/orta/cocoapods-keys/blob/4153cfc7621a89c7ae3f96bb0285d9602f41e267/lib/key_master.rb
data_length = dotenv.values.map(&:length).reduce(0, :+) * rand(20..29)
data = SecureRandom.base64(data_length)
data += '\\"' # this is a sentinel for keys that contain literal quote characters

used_indexes = Set.new
indexed_keys = {}
dotenv.each do |key, escaped_value|
  indexed_keys[key] = []
  # ReadDotEnv.rb escapes these, but we need to unescape them for use with obfuscation
  value = escaped_value.gsub('\"', '"')
  value.chars.each_with_index do |char, char_index|
    loop do # we loop until we break to avoid index collisions
      if char == '"'
        index = data.length - 1 # point to the sentinel for quote characters
        indexed_keys[key][char_index] = index
        break
      else
        index = SecureRandom.random_number data.length
        unless used_indexes.include?(index)
          data[index] = char # store this character of the key in the obfuscated data
          indexed_keys[key][char_index] = index # point to the index in data
          used_indexes << index # mark the index in data as already in-use
          break
        end
      end
    end
  end
end

c_strings = indexed_keys.map.with_index do |obj, index|
  _key, value = obj
  data_indexes = value.map { |i| "[data characterAtIndex:#{i}]" }
  "char string#{index}[#{value.length + 1}] = {#{data_indexes.join(', ')}, '\\0'};"
end
objc_dict = indexed_keys.map.with_index do |obj, index|
  key, _value = obj
  "@\"#{key}\": [NSString stringWithCString:string#{index} encoding:NSUTF8StringEncoding]"
end

template = <<~EOF
  static NSDictionary *DOT_ENV;
  
  @interface ReactNativeConfigTrampoline: NSObject
  @end
  
  @implementation ReactNativeConfigTrampoline
  
  + (void)load
  {
    NSString *data = @"#{data.gsub('\\', '\\\\\\').gsub('"', '\\"')}";
    #{c_strings.join("\n  ")}
    DOT_ENV = @{
      #{objc_dict.join(", \n    ")}
    };
  }
  
  @end
EOF

# write it so that ReactNativeConfig.m can return it
path = File.join(m_output_path, 'GeneratedDotEnv.m')
File.open(path, 'w') { |f| f.puts template }

# create header file with defines for the Info.plist preprocessor
info_plist_defines_objc = dotenv.map { |k, v| %Q(#define RNC_#{k}  #{v}) }.join("\n")

# write it so the Info.plist preprocessor can access it
path = File.join(ENV["BUILD_DIR"], "GeneratedInfoPlistDotEnv.h")
File.open(path, "w") { |f| f.puts info_plist_defines_objc }

puts "Wrote to #{path}"
