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
            return "\($0.key) = \(try xcconfigRawValue(for: $0.value))"
        }.joined(separator: "\n")
    }
    
    func androidEnvEntry() throws -> String {
        return try env
            .map { return "\($0.key) = \(try androidEnvRawValue(for: $0.value))" }
            .sorted()
            .joined(separator: "\n")
    }
    
    // MARK: - Private
    
    private func xcconfigRawValue(for jsonEntry: JSONEntry) throws -> String {
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
    
    private func androidEnvRawValue(for jsonEntry: JSONEntry) throws -> String {
        switch jsonEntry.typedValue {
        case let .url(url):
            return url.absoluteString
        case let .string(string):
            return string
        case let .int(int):
            return "\(int)"
        }
    }
}
