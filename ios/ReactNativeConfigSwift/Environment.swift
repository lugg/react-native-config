//
//  Environment.swift
//  ReactNativeConfigSwift
//
//  Created by Stijn on 29/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation

//⚠️ File is generated and ignored in git. To change it change /PrepareReactNativeconfig/main.swift

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
   
    public static func plist() throws ->  Plist {
        
        guard let infoDict = Bundle.main.infoDictionary else {
            throw Error.noInfoDictonary
        }
        
        let data = try JSONSerialization.data(withJSONObject: infoDict, options: .sortedKeys)
        
        return try JSONDecoder().decode(Plist.self, from: data)
    }
    
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
    
    public enum Case: String, CaseIterable {
    
            case API_URL

    }
    
}
