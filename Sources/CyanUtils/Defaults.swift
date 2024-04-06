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
        defaults.integer(forKey: key)
    }
}

extension Float: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Float? {
        defaults.float(forKey: key)
    }
}

extension Double: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Double? {
        defaults.double(forKey: key)
    }
}

extension String: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        defaults.string(forKey: key)
    }
}

extension Bool: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        defaults.bool(forKey: key)
    }
}

extension Array: ConstructibleFromDefaults where Element: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Array<Element>? {
        defaults.array(forKey: key) as? Self
    }
}

extension URL: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> URL? {
        defaults.url(forKey: key)
    }
}

extension Dictionary: ConstructibleFromDefaults where Key == String, Value: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Dictionary<String, Value>? {
        defaults.dictionary(forKey: key) as? Self
    }
}

extension Data: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Data? {
        defaults.data(forKey: key)
    }
}

@propertyWrapper
public struct Defaults<T> where T: ConstructibleFromDefaults {
    
    public let key: String
    public var defaultValue: T {
        `default`()
    }
    private let `default`: () -> T
    
    @available(*, deprecated, renamed: "init(key:defaultValue:)", message: "Use init(key:defaultValue:) instead")
    public init(key: String, default: @escaping () -> T) {
        self.key = key
        self.default = `default`
    }
    
    public init(key: String, defaultValue: @autoclosure @escaping () -> T) {
        self.key = key
        self.default = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            .from(.standard, with: key) ?? defaultValue
        }
        
        nonmutating set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
}

public protocol DefaultsCompatible {
    static func defaultValue() -> Self
}

extension Int: DefaultsCompatible {
    public static func defaultValue() -> Self { 0 }
}

extension Float: DefaultsCompatible {
    public static func defaultValue() -> Self { 0 }
}

extension Double: DefaultsCompatible {
    public static func defaultValue() -> Self { 0 }
}

extension Bool: DefaultsCompatible {
    public static func defaultValue() -> Self { false }
}

extension Defaults where T: DefaultsCompatible {
    public init(key: String) {
        self.init(key: key, defaultValue: T.defaultValue())
    }
}
