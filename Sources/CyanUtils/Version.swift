//
//  Created by ktiays on 2024/9/5.
//  Copyright (c) 2024 Helixform. All rights reserved.
// 

import Foundation

public struct Version: Codable, CustomStringConvertible {
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public enum DecodeError: String, Error {
        case invalidFormat = "Invalid format"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        let sequence = text.split(separator: ".")
        let count = sequence.count
        if count > 3 {
            throw DecodeError.invalidFormat
        }
        
        func atoi<S>(_ text: S) throws -> Int where S: StringProtocol {
            if let value = Int(text), value >= 0 {
                return value
            }
            throw DecodeError.invalidFormat
        }
        
        var major = 0, minor = 0, patch = 0
        if count >= 1 {
            major = try atoi(sequence[0])
        }
        if count >= 2 {
            minor = try atoi(sequence[1])
        }
        if count >= 3 {
            patch = try atoi(sequence[2])
        }
        
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        return lhs.major < rhs.major || (lhs.major == rhs.major && lhs.minor < rhs.minor) || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
}
