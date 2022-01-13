//
//  Created by Cyandev on 2021/6/21.
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
