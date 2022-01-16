//
//  Created by ktiays on 2022/1/16.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

@propertyWrapper public class Weak<T> where T: AnyObject {
    
    public weak var wrappedValue: T?
    
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
}
