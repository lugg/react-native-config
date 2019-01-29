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
    
    print("🚀 preparing build environment variables in \(environmentFile.path)")
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

