//
//  Created by Cyandev on 2021/6/21.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

import Foundation

public struct ExtensionNamespace<Object> {
    let extendedObject: Object
}

public protocol CyanExtending { }

public extension CyanExtending {
    
    var cyan: ExtensionNamespace<Self> {
        return .init(extendedObject: self)
    }
    
}
