//
//  Created by Cyandev on 2021/6/21.
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
