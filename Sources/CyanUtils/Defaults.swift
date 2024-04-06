//
//  Created by ktiays on 2021/6/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

// MARK: Property Wrapper for UserDefaults

public protocol ConstructibleFromDefaults {
    static func from(_ defaults: UserDefaults, with key: String) -> Self?
}

public protocol DefaultsWriting {
    func write(to defaults: UserDefaults, with key: String)
}

private func getPrimitiveDefaultsValue<T>(of type: T.Type,
                                          from defaults: UserDefaults,
                                          with key: String,
                                          objCType: String) -> T? {
    guard let number = defaults.object(forKey: key) as? NSNumber else {
        return nil
    }
    let actualObjCType = String(cString: number.objCType)
    guard objCType == actualObjCType else {
        return nil
    }
    return number as? T
}

extension Int: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        return getPrimitiveDefaultsValue(of: Int.self, from: defaults, with: key, objCType: "q")
    }
}

extension Float: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Float? {
        return getPrimitiveDefaultsValue(of: Float.self, from: defaults, with: key, objCType: "f")
    }
}

extension Double: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Double? {
        return getPrimitiveDefaultsValue(of: Double.self, from: defaults, with: key, objCType: "d")
    }
}

extension String: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        defaults.string(forKey: key)
    }
}

extension Bool: ConstructibleFromDefaults {
    public static func from(_ defaults: UserDefaults, with key: String) -> Self? {
        return getPrimitiveDefaultsValue(of: Bool.self, from: defaults, with: key, objCType: "c")
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
            let userDefaults = UserDefaults.standard
            if let customWriting = newValue as? DefaultsWriting {
                customWriting.write(to: userDefaults, with: key)
            } else {
                userDefaults.set(newValue, forKey: key)
            }
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
