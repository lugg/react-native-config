//
//  PlistEntry.swift
//  ReactNativeConfigSwift
//
//  Created by Stijn on 30/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation

public struct PlistEntry: Codable {
    public let value: String
    public let valueType: String
    
    public let typedValue: PossibleTypes
    
    public enum PossibleTypes {
        
        public typealias RawValue = String
        
        case url(URL)
        case string(String)
        case int(Int)
    
    }
    
    public enum CodingKeys: String, CodingKey {
        case value
        case valueType
    }
    
    public enum Error: Swift.Error {
        case couldNotResolveType(String)
        case invalidUrl(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        valueType = try container.decode(String.self, forKey: .valueType)
        
        switch valueType {
        case "Url":
            guard let url = URL(string: value) else {
                throw Error.invalidUrl(value)
            }
            
            typedValue = .url(url)
        case "String":
            typedValue = .string(value)
        case "Int":
            guard let int = Int(value) else {
                throw Error.invalidUrl(value)
            }
            
            typedValue = .int(int)
        default:
            throw Error.couldNotResolveType(valueType)
        }
        
    }
}
