//
//  EnvironmentCustomPlist.swift
//  ReactNativeConfigSwift
//
//  Created by Stijn on 30/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation

//⚠️ File is generated and ignored in git. To change it change /PrepareReactNativeconfig/main.swift

public struct Plist: Codable {
    
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
    public let API_URL: String

}