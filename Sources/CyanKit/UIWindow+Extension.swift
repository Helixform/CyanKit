//
//  Created by Cyandev on 2021/6/21.
//

#if os(iOS)
import UIKit

extension UIWindow: CyanExtending { }

public extension ExtensionNamespace where Object: UIWindow {
    
    var topViewController: UIViewController? {
        return extendedObject.rootViewController?.cyan.topViewController
    }
    
}
#endif
