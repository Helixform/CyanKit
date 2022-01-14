//
//  Created by Cyandev on 2021/6/21.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIViewController: CyanExtending { }

public extension ExtensionNamespace where Object: UIViewController {
    
    var topViewController: UIViewController? {
        if let presentedViewController = extendedObject.presentedViewController {
            return presentedViewController.cyan.topViewController
        }
        return extendedObject
    }
    
}
#endif
