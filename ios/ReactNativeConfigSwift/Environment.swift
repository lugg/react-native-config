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
    
    @objc public class func allValuesDictionary() -> [String : String] {
        
        var dict = [String : String]()
        
         Environment.allConstants.forEach { _case in
            dict[_case.key.rawValue] = _case.value
        }
        return dict
    }
   
public static let allConstants: [Environment.Case: String] = [API_URL: "https://staging.armada.bolides.be"]
    
    public enum Case: String, CaseIterable {
    
          case API_URL

    }
    
}
