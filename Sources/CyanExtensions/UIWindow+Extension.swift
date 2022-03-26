//
//  Created by Cyandev on 2021/6/21.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

#if os(iOS)
import UIKit

public extension ExtensionNamespace where Object: UIWindow {
    
    var topViewController: UIViewController? {
        return extendedObject.rootViewController?.cyan.topViewController
    }
    
}
#endif
