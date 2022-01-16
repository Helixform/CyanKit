//
//  Created by ktiays on 2022/1/16.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

@propertyWrapper public class Weak<T> where T: AnyObject {
    
    private weak var _wrappedValue: T?
    
    public var wrappedValue: T? {
        get { _wrappedValue }
        set { _wrappedValue = newValue }
    }
    
    public init(wrappedValue: T?) {
        _wrappedValue = wrappedValue
    }
    
}
