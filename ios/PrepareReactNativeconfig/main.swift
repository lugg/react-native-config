//
//  main.swift
//  PrepareReactNativeconfig
//
//  Created by Stijn on 29/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation
import ZFile

let currentFolder = FileSystem.shared.currentFolder
enum Error: Swift.Error {
    case noPrepareInSwiftFile
    case missinIOSFolder
}

do {
    var iosFolder: FolderProtocol!
   
    do {
      iosFolder = try currentFolder.subfolder(named: "ios")
    } catch {
        guard currentFolder.name == "ios" else {
            throw Error.missinIOSFolder
        }
        
       iosFolder = currentFolder
    }
    
    let environmentFile = try iosFolder.parentFolder().parentFolder().parentFolder().parentFolder().file(named: ".env")
    // /Users/doozmen/Documents/dooZ/active/WizKey/dev.nosync/BolidesApp/Carthage/Checkouts/react-native-config/ios/ReactNativeConfig/GeneratedInfoPlistDotEnv.h
    let sourcesFolder = try iosFolder.subfolder(named: "ReactNativeConfig")
    
    let generatedInfoPlistDotEnvFile = try sourcesFolder.createFileIfNeeded(named: "GeneratedInfoPlistDotEnv.h")
    let generatedDotEnvFile = try sourcesFolder.createFileIfNeeded(named: "GeneratedDotEnv.m")
    let generatedSwiftFile = try iosFolder.subfolder(named: "ReactNativeConfigSwift").createFileIfNeeded(named: "Environment.swift")
    
    FileHandle.standardOutput.write("🚀 ReactNativeConfig main.swift\nPreparing build environment variables in \(environmentFile.path)\n...\n\n".data(using: .utf8)!)
    
    let text: [(info: String, dotEnv: String, swift: String)] = try environmentFile.readAllLines().compactMap { textLine in
        let components = textLine.components(separatedBy: "=")
        
        guard
            components.count == 2,
            let key = components.first,
            let value = components.last else {
            return nil
        }
        // #define __RN_CONFIG_API_URL  https://myapi.com
        // #define DOT_ENV @{ @"API_URL":@"https://myapi.com" };

        return (
            info: "#define __RN_CONFIG_\(key) \(value)",
            dotEnv: "#define DOT_ENV @{ @\"\(key)\":@\"\(value)\"};",
            swift: "    case \(key) = \"\(value)\""
        )
    }
    
    try generatedInfoPlistDotEnvFile.write(data: text.map { $0.info }.joined(separator: "\n").data(using: .utf8)!)
    try generatedDotEnvFile.write(data: text.map { $0.dotEnv }.joined(separator: "\n").data(using: .utf8)!)
    
    let headerSwift = """
    //
    //  Environment.swift
    //  ReactNativeConfigSwift
    //
    //  Created by Stijn on 29/01/2019.
    //  Copyright © 2019 Pedro Belo. All rights reserved.
    //

    import Foundation

    enum Environment: String, CaseIterable {
    """
    var swiftLines = [headerSwift]
    swiftLines.append(contentsOf: text.map { $0.swift })
    swiftLines.append("}")
    
    try generatedSwiftFile.write(data: swiftLines.joined(separator: "\n").data(using: .utf8)!)
    FileHandle.standardOutput.write("🚀 ReactNativeConfig main.swift ✅\n\n".data(using: .utf8)!)

    exit(EXIT_SUCCESS)
} catch {
    FileHandle.standardError.write("""
    ❌
        Could not find '.env' file in your root React Native project.
        The error was:
        \(error)
    ❌
        ♥️ Fix it by adding .env file to root with `API_URL=https://myapi.com` or more
    """.data(using: .utf8)!
    )
    exit(EXIT_FAILURE)
}

