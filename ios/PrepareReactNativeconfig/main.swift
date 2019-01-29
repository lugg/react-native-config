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

do {
    let environmentFile = try currentFolder.parentFolder().parentFolder().parentFolder().parentFolder().file(named: ".env")
    // /Users/doozmen/Documents/dooZ/active/WizKey/dev.nosync/BolidesApp/Carthage/Checkouts/react-native-config/ios/ReactNativeConfig/GeneratedInfoPlistDotEnv.h
    let sourcesFolder = try currentFolder.subfolder(named: "ReactNativeConfig")
    
    let generatedInfoPlistDotEnvFile = try sourcesFolder.file(named: "GeneratedInfoPlistDotEnv.h")
    let generatedDotEnvFile = try sourcesFolder.file(named: "GeneratedDotEnv.m")
    
    print("🚀 preparing build environment variables in \(environmentFile.path)")
    
    let text: [(info: String, dotEnv: String)] = try environmentFile.readAllLines().compactMap { textLine in
        let components = textLine.components(separatedBy: "=")
        
        guard
            components.count == 2,
            let key = components.first,
            let value = components.last else {
            return nil
        }
        // #define __RN_CONFIG_API_URL  https://myapi.com
        // #define DOT_ENV @{ @"API_URL":@"https://myapi.com" };

        return (info: "#define __RN_CONFIG_\(key) \(value)", dotEnv: "#define DOT_ENV @{ @\"\(key)\":@\"\(value)\"};")
    }
    
    try generatedInfoPlistDotEnvFile.write(data: text.map { $0.info }.joined(separator: "\n").data(using: .utf8)!)
    try generatedDotEnvFile.write(data: text.map { $0.dotEnv }.joined(separator: "\n").data(using: .utf8)!)

    exit(EXIT_SUCCESS)
} catch {
    print("""
    ❌
        Could not find '.env' file in your root React Native project.
        The error was:
        \(error)
    ❌
        ♥️ Fix it by adding .env file to root with `API_URL=https://myapi.com` or more
    """)
    exit(EXIT_FAILURE)
}

