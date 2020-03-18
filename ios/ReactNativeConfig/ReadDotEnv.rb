#!/usr/bin/env ruby
# frozen_string_literal: true

# Allow utf-8 charactor in config value
# For example, APP_NAME=中文字符
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# TODO: introduce a parameter which controls how to build relative path
def read_dot_env(envs_root)
  defaultEnvFile = '.env'
  puts "going to read env file from root folder #{envs_root}"

  # pick a custom env file if set
  if File.exist?('/tmp/envfile')
    custom_env = true
    file = File.read('/tmp/envfile').strip
  else
    custom_env = false
    file = ENV['ENVFILE'] || defaultEnvFile
  end

  dotenv = begin
    # https://regex101.com/r/cbm5Tp/1
    dotenv_pattern = /^(?:export\s+|)(?<key>[[:alnum:]_]+)=((?<quote>["'])?(?<val>.*?[^\\])\k<quote>?|)$/

    path = File.expand_path(File.join(envs_root, file.to_s))
    if File.exist?(path)
      raw = File.read(path)
    elsif File.exist?(file)
      raw = File.read(file)
    else
      defaultEnvPath = File.expand_path(File.join(envs_root, "../#{defaultEnvFile}"))
      unless File.exist?(defaultEnvPath)
        # try as absolute path
        defaultEnvPath = defaultEnvFile
      end
      defaultRaw = File.read(defaultEnvPath)
      raw = defaultRaw + "\n" + raw if defaultRaw
    end

    raw.split("\n").inject({}) do |h, line|
      m = line.match(dotenv_pattern)
      next h if m.nil?

      key = m[:key]
      # Ensure string (in case of empty value) and escape any quotes present in the value.
      val = m[:val].to_s.gsub('"', '\"')
      h.merge(key => val)
    end
    rescue Errno::ENOENT
      puts('**************************')
      puts('*** Missing .env file ****')
      puts('**************************')
      return [{}, false] # set dotenv as an empty hash
  end
  [dotenv, custom_env]
end
