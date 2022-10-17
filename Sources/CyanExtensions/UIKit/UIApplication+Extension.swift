//
//  Created by Cyandev on 2021/6/21.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIApplication: CyanExtending { }

public extension ExtensionNamespace where Object: UIApplication {
    
    var keyWindow: UIWindow? {
        let activeWindowScenes = extendedObject.connectedScenes
            .compactMap({ return $0 as? UIWindowScene })
            .filter({ $0.activationState == .foregroundActive })
        guard let firstWindowScene = activeWindowScenes.first else {
            return nil
        }
        if #available(iOS 15.0, *) {
            return firstWindowScene.keyWindow
        } else {
            return firstWindowScene.windows
                .filter({ $0.isKeyWindow })
                .first
        }
    }
    
}
#endif
