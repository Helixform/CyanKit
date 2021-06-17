//
//  Created by ktiays on 2021/6/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

// MARK: Property Wrapper for UserDefaults

public protocol ConstructibleFromDefaults {
    
    static func from(_ defaults: UserDefaults, with key: String) -> Self?
    
}

extension Int: ConstructibleFromDefaults {
    
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        return defaults.integer(forKey: key)
    }
    
}

extension String: ConstructibleFromDefaults {
    
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        return defaults.string(forKey: key)
    }
    
}

extension Bool: ConstructibleFromDefaults {
    
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        return defaults.bool(forKey: key)
    }
    
}

@propertyWrapper public struct Defaults<T> where T: ConstructibleFromDefaults {
    
    public let key: String
    public let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return .from(.standard, with: key) ?? defaultValue
        }
        
        nonmutating set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
}
