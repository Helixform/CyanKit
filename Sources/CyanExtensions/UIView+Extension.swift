//
//  Created by ktiays on 2022/3/26.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit

extension UIView: CyanExtending { }

public extension ExtensionNamespace where Object: UIView {
    
    var viewController: UIViewController? {
        var responder: UIResponder? = extendedObject.next
        while responder != nil && !(responder is UIViewController) {
            responder = responder?.next
        }
        return responder as? UIViewController
    }
    
}

#endif
