//
//  main.swift
//  PrepareReactNativeconfig
//
//  Created by Stijn on 29/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation
import ZFile
import SignPost

let currentFolder = FileSystem.shared.currentFolder
enum Error: Swift.Error {
    case noPrepareInSwiftFile
    case missingIOSFolder
}

let signPost = SignPost.shared
signPost.message("🚀 ReactNativeConfig main.swift\nExecuted at path \(currentFolder.path)\n...")
let envFileName_debug = ".env.debug.json"
let envFileName_release = ".env.release.json"
var envFileName_local = ".env.local.json"

do {
    
    var reactNativeFolder = try currentFolder.parentFolder()
    
    // ios environment .xcconfig files
    
    var environmentFileDebug: FileProtocol!
    var environmentFileRelease: FileProtocol!
    var environmentFileLocal: FileProtocol?

    
    
    var androidFolder: FolderProtocol!
    var iosFolder: FolderProtocol!
    
    do {
        SignPost.shared.verbose("PrepareReactNativeconfig run from post install in node_modules folder")
        environmentFileDebug = try reactNativeFolder.file(named: envFileName_debug)
        environmentFileRelease = try reactNativeFolder.file(named: envFileName_release)
        do { environmentFileLocal = try reactNativeFolder.file(named: envFileName_local) } catch { signPost.message("💁🏻‍♂️ If you would like you can add \(envFileName_local) to have a local config. Ignoring for now") }
        iosFolder = try reactNativeFolder.subfolder(named: "/Carthage/Checkouts/react-native-config/ios")
        androidFolder = try reactNativeFolder.subfolder(named: "android")
    } catch {
        
        reactNativeFolder = try reactNativeFolder.parentFolder().parentFolder().parentFolder()
        
        SignPost.shared.verbose("PrepareReactNativeconfig run from building in the carthage checkouts folder")
        environmentFileDebug = try reactNativeFolder.file(named: envFileName_debug)
        environmentFileRelease = try reactNativeFolder.file(named: envFileName_release)
        do { environmentFileLocal = try reactNativeFolder.file(named: envFileName_local) } catch { signPost.message("💁🏻‍♂️ If you would like you can add \(envFileName_local) to have a local config. Ignoring for now") }

        iosFolder = currentFolder
        androidFolder = try reactNativeFolder.subfolder(named: "android")
    }
    
    // Generate ios config files
    
    let frameworkSwiftFolder = try iosFolder.subfolder(named: "ReactNativeConfigSwift")
    
    let generatedEnvironmentSwiftFile = try frameworkSwiftFolder.createFileIfNeeded(named: "Environment.swift")
    let generatedPlistFile = try iosFolder.subfolder(named: "ReactNativeConfigSwift").createFileIfNeeded(named: "Info.plist")
    let generatedPlistSwiftFile = try frameworkSwiftFolder.createFileIfNeeded(named: "Plist.swift")
    
    let debugXconfigFile = try iosFolder.createFileIfNeeded(named: "Debug.xcconfig")
    let env_debug: Env = try JSONDecoder().decode(Env.self, from:  try environmentFileDebug.read())

    try debugXconfigFile.write(string: try env_debug.xcconfigEntry())
    
    let releaseXconfigFile = try iosFolder.createFileIfNeeded(named: "Release.xcconfig")
    let env_release: Env = try JSONDecoder().decode(Env.self, from:  try environmentFileRelease.read())

    try releaseXconfigFile.write(string: try env_release.xcconfigEntry())
    
    var env_local: Env?
    
    if let environmentFile_local = environmentFileLocal {
        let localXconfigFile = try iosFolder.createFileIfNeeded(named: "Local.xcconfig")
        env_local = try JSONDecoder().decode(Env.self, from: try environmentFile_local.read())
        
        try localXconfigFile.write(string: try env_local!.xcconfigEntry())

    }
    
    // android config files
    
    // android .env files
    let androidEnvironmentFileDebug: FileProtocol = try androidFolder.createFileIfNeeded(named: ".env.debug")
    let androidEnvironmentFileRelease: FileProtocol = try androidFolder.createFileIfNeeded(named: ".env.release")
    var androidEnvironmentFileLocal: FileProtocol?
    
    try androidEnvironmentFileDebug.write(string: try env_debug.androidEnvEntry())
    try androidEnvironmentFileRelease.write(string: try env_release.androidEnvEntry())
    
    if let env_local = env_local {
        androidEnvironmentFileLocal = try androidFolder.createFileIfNeeded(named: ".env.release")

        try androidEnvironmentFileLocal?.write(string: try env_local.xcconfigEntry())
    }
    
    SignPost.shared.message("""
        🚀 Env read from
            \(environmentFileDebug!)
            \(environmentFileRelease!)
            \(String(describing: environmentFileLocal))
         ...
        """
    )
    
    // iOS
    // Only 1 environment read is good. Values come form configuration files
    
    let text: [(case: String, plistVar: String, plistVarString: String, xmlEntry: String)] = env_debug.env.enumerated().compactMap {
        let key = $0.element.key
        let typedValue = $0.element.value.typedValue
        let swiftTypeString = typedValue.typeSwiftString
        let xmlType = typedValue.typePlistString
        
        return (
            case: "case \(key)",
            plistVar: "public let \(key): \(swiftTypeString)",
            plistVarString: "\(key): \\(\(key))",
            xmlEntry: """
            <key>\(key)</key>
            <\(xmlType)>$(\(key))</\(xmlType)>
            """
        )
    }
    
    let allCases: String = text
        .map { $0.case }
        .map {"      \($0)"}
        .joined(separator: "\n")
    
    SignPost.shared.verbose("Writing environment variables to swift files and plist")
    
    let swiftLines = """
    //
    //  Environment.swift
    //  ReactNativeConfigSwift
    //
    //  Created by Stijn on 29/01/2019.
    //  Copyright © 2019 Pedro Belo. All rights reserved.
    //

    import Foundation

    /// ⚠️ File is generated and ignored in git. To change it change /PrepareReactNativeconfig/main.swift
    @objc public class Environment: NSObject {
        
        public enum Error: Swift.Error {
            case noInfoDictonary
            case infoDictionaryNotReadableAsDictionary
        }
        
        @objc public class func allValuesDictionary() throws -> [String : String] {
            
            var dict = [String : String]()
            
             try Environment.allConstants().forEach { _case in
                dict[_case.key.rawValue] = _case.value
            }
            return dict
        }
       
        /// All custom environment dependend keys that are added to the plist and in the dictionary
        @objc public func allCustomKeys() -> [String] {
            return Case.allCases.map { $0.rawValue }
        }
        
        /// Keys used in the plist of ReactNativeConfigSwift module when building for the selected configuration (Debug or Release)
        public enum Case: String, CaseIterable {
            
    \(allCases)
            
        }
        
        /// Plist containing custom variables that are set from the .env.debug.json or .env.release.json dependend on the configuration you build for.
        public static func plist() throws ->  Plist {
            
            guard let infoDict = Bundle(for: Environment.self).infoDictionary else {
                throw Error.noInfoDictonary
            }
            
            let data = try JSONSerialization.data(withJSONObject: infoDict, options: .prettyPrinted)
            
            return try JSONDecoder().decode(Plist.self, from: data)
        }
        
        /// If using swift use plist()
        /// In Objective-C you can access this dictionary containing all custom environment dependend keys.
        /// They are set from the .env.debug.json or .env.release.json dependend on the configuration you build for.
        public static func  allConstants() throws ->  [Environment.Case: String] {
            var result = [Case: String]()
            
            let plist = try Environment.plist()
            let data = try JSONEncoder().encode(plist)
            
            guard let dict: [String: String] = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String : String] else {
                throw Error.infoDictionaryNotReadableAsDictionary
            }
            
            dict.forEach {
                
                guard let key = Case(rawValue: $0.key) else {
                    return
                }
                result[key] = $0.value
            }
            
            return result
        }
        
        
    }

    """
   
    try generatedEnvironmentSwiftFile.write(data: swiftLines.data(using: .utf8)!)
    
    let plistVar: String = text
        .map { $0.plistVar }
        .map {"    \($0)"}
        .joined(separator: "\n")
    let plistVarString: String = text
        .map { $0.plistVarString }
        .map { "            * \($0)" }
        .joined(separator: "\n")
    
    let plistLinesSwift = """
    //
    //  EnvironmentCustomPlist.swift
    //  ReactNativeConfigSwift
    //
    //  Created by Stijn on 30/01/2019.
    //  Copyright © 2019 Pedro Belo. All rights reserved.
    //

    import Foundation

    //⚠️ File is generated and ignored in git. To change it change /PrepareReactNativeconfig/main.swift

    public struct Plist: Codable, CustomStringConvertible {
        
        
        // These are the normal plist things

        public let CFBundleDevelopmentRegion: String
        public let CFBundleExecutable: String
        public let CFBundleIdentifier: String
        public let CFBundleInfoDictionaryVersion: String
        public let CFBundleName: String
        public let CFBundlePackageType: String
        public let CFBundleShortVersionString: String
        public let CFBundleVersion: String
        
        // Custom plist properties are added here
    \(plistVar)
        
        public var description: String {
            return \"""
            Environment Plist
    
            // Config variable of Framework ReactNativeConfigSwift
    
                * CFBundleDevelopmentRegion = \\(CFBundleDevelopmentRegion)
                * CFBundleExecutable = \\(CFBundleExecutable)
                * CFBundleIdentifier = \\(CFBundleIdentifier)
                * CFBundleInfoDictionaryVersion = \\(CFBundleInfoDictionaryVersion)
                * CFBundleName = \\(CFBundleName)
                * CFBundlePackageType = \\(CFBundlePackageType)
                * CFBundleShortVersionString = \\(CFBundleShortVersionString)
                * CFBundleVersion = \\(CFBundleVersion)
    
            // Custom environment dependend constants from .env.debug.json or .env.release.json 

    \(plistVarString)
            \"""
        }
    
    }
    
    """
    try generatedPlistSwiftFile.write(string: plistLinesSwift)
    
    let plistLinesXmlText: String = text
        .map { $0.xmlEntry }
        .map {"      \($0)"}
        .joined(separator: "\n")
    
    let plistLinesXml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>$(DEVELOPMENT_LANGUAGE)</string>
        <key>CFBundleExecutable</key>
        <string>$(EXECUTABLE_NAME)</string>
        <key>CFBundleIdentifier</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>$(PRODUCT_NAME)</string>
        <key>CFBundlePackageType</key>
        <string>FMWK</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleVersion</key>
        <string>$(CURRENT_PROJECT_VERSION)</string>
        \(plistLinesXmlText)
    </dict>
    </plist>
    """
    
    try generatedPlistFile.write(string: plistLinesXml)
    SignPost.shared.message("🚀 ReactNativeConfig main.swift ✅")
    
    exit(EXIT_SUCCESS)
} catch {
    SignPost.shared.error("""
    ❌ Prepare React Native Config
    
         \(error)
    
    ❌
        ♥️ Fix it by adding \(envFileName_debug) & \(envFileName_release) at <#react native#>/
    """
    )
    exit(EXIT_FAILURE)
}

