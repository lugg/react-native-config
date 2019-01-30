//
//  Env.swift
//  PrepareReactNativeconfig
//
//  Created by Stijn on 30/01/2019.
//  Copyright © 2019 Pedro Belo. All rights reserved.
//

import Foundation

struct Env: Decodable {
    let env: [String: JSONEntry]
    
    func xcconfigEntry() throws -> String {
        return try env.map {
            return "\($0.key) = \(try rawValue(for: $0.value))"
        }.joined(separator: "\n")
    }
    
    private func rawValue(for jsonEntry: JSONEntry) throws -> String {
        switch jsonEntry.typedValue {
        case let .url(url):
            return url.absoluteString
                .replacingOccurrences(of: "http://", with: "http:\\/\\/")
                .replacingOccurrences(of: "https://", with: "https:\\/\\/")
        case let .string(string):
            return string
        case let .int(int):
            return "\(int)"
        }
    }
}
