#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'ReadDotEnv'

envs_root = ARGV[0]
m_output_path = ARGV[1]
puts "reading env file from #{envs_root} and writing .m to #{m_output_path}"

# Allow utf-8 charactor in config value
# For example, APP_NAME=中文字符
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

dotenv, custom_env = read_dot_env(envs_root)
puts "read dotenv #{dotenv}"

# create obj file that sets DOT_ENV as a NSDictionary
dotenv_objc = dotenv.map { |k, v| %(@"#{k}":@"#{v.chomp}") }.join(',')
template = <<EOF
  #define DOT_ENV @{ #{dotenv_objc} };
EOF

# write it so that ReactNativeConfig.m can return it
path = File.join(m_output_path, 'GeneratedDotEnv.m')
File.open(path, 'w') { |f| f.puts template }

File.delete('/tmp/envfile') if custom_env

puts "Wrote to #{path}"
