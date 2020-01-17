#!/usr/bin/env ruby
# frozen_string_literal: true

# Allow utf-8 charactor in config value
# For example, APP_NAME=中文字符
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def get_env_files(envs_root, default_env_file)
  # [, env, development, local]
  file_arr = default_env_file.split('.')
  env_file_name = ".#{file_arr[1]}.#{file_arr[2]}"

  env_file = "#{envs_root}/#{env_file_name}"
  local_env_file = "#{env_file}.local"

  root_env_file = "#{envs_root}/../../env/#{env_file_name}"
  local_root_env_file = "#{root_env_file}.local"

  specified_env_file = ENV['ENVFILE']

  return [
    local_env_file,
    env_file,
    local_root_env_file,
    root_env_file
  ].select{ |item|
    specified_env_file ? item[item.length - specified_env_file.length, item.length] == specified_env_file : true
  }
end

# TODO: introduce a parameter which controls how to build relative path
def read_dot_env(envs_root)
  defaultEnvFile = '.env.development'
  puts "going to read env file from root folder #{envs_root}"

  env_files = get_env_files(envs_root, defaultEnvFile)
  target_env_file_path = ''

  for path in env_files
    if File.exist?(path)
      target_env_file_path = path
      break
    end
  end

  dotenv = begin
    # https://regex101.com/r/cbm5Tp/1
    dotenv_pattern = /^(?:export\s+|)(?<key>[[:alnum:]_]+)=((?<quote>["'])?(?<val>.*?[^\\])\k<quote>?|)$/

    if File.exist?(target_env_file_path)
      raw = File.read(target_env_file_path)
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
      puts("*** Missing #{defaultEnvFile} file ****")
      puts('**************************')
      return [{}, false] # set dotenv as an empty hash
  end

  [dotenv, false]
end
