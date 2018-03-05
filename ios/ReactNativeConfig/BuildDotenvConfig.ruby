#!/usr/bin/env ruby

# Allow utf-8 charactor in config value
# For example, APP_NAME=中文字符
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8


def searchPath(file)
  # find that above node_modules/react-native-config/ios/
  path = File.join(Dir.pwd, "../../../#{file}")
  if File.exists?(path)
    return path
  elsif File.exists?(file)
    return path
  else
    return nil
  end
end


def parseFile(path)
  begin
    # https://regex101.com/r/cbm5Tp/1
    dotenv_pattern = /^(?:export\s+|)(?<key>[[:alnum:]_]+)=((?<quote>["'])?(?<val>.*?[^\\])\k<quote>?|)$/

    if (!path.nil? && File.exists?(path))
      raw = File.read(path)
    else
      raw = ""
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
    puts("**************************")
    puts("*** Missing .env file ****")
    puts("**************************")
    {} # set dotenv as an empty hash
  end
end

def mergeData(target, source)

end


defaultEnvFile = ".env"
envPrefix = "ios"

# pick a custom env file if set
if File.exists?("/tmp/envfile")
  custom_env = true
  file = File.read("/tmp/envfile").strip
else
  custom_env = false
  file = ENV["ENVFILE"] || defaultEnvFile
end

puts "Reading env from #{file}"


path = searchPath(file)
if path.nil?
  path = searchPath(defaultEnvFile)
end

data = parseFile(path)

envPath = searchPath("#{file}.#{envPrefix}")
envData = parseFile(envPath)

data = data.merge envData

# create obj file that sets DOT_ENV as a NSDictionary
dotenv_objc = data.map {|k, v| %Q(@"#{k}":@"#{v.chomp}")}.join(",")
template = <<EOF
  #define DOT_ENV @{ #{dotenv_objc} };
EOF

# write it so that ReactNativeConfig.m can return it
resultPath = File.join(ENV["SYMROOT"], "GeneratedDotEnv.m")
File.open(resultPath, "w") {|f| f.puts template}

# create header file with defines for the Info.plist preprocessor
info_plist_defines_objc = data.map {|k, v| %Q(#define __RN_CONFIG_#{k}  #{v})}.join("\n")

# write it so the Info.plist preprocessor can access it
resultPath = File.join(ENV["BUILD_DIR"], "GeneratedInfoPlistDotEnv.h")
File.open(resultPath, "w") {|f| f.puts info_plist_defines_objc}

if custom_env
  File.delete("/tmp/envfile")
end

puts "Wrote to #{resultPath}"
