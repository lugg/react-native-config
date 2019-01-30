//
//  UrlEscaped.swift
//  ReactNativeConfigSwift
//
//  Created by Stijn on 30/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation

public struct URLEscaped: Codable {
    
    public let url: URL
    
    public enum Error: Swift.Error {
        case invalidUrlString(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let urlString = try container.decode(String.self).replacingOccurrences(of: "\\", with: "")
    
        guard let url = URL(string: urlString) else {
            throw Error.invalidUrlString(urlString)
        }
        
        self.url = url
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url.absoluteString)
    }
    
}
