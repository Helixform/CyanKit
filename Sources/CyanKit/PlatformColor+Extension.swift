//
//  Created by ktiays on 2021/5/2.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

extension PlatformColor {
    
    convenience init(lightColor: PlatformColor, darkColor: PlatformColor) {
#if os(iOS)
        self.init(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return lightColor
            }
        })
#else
        self.init(name: nil, dynamicProvider: { appearance in
            if appearance.name == .darkAqua {
                return darkColor
            } else {
                return lightColor
            }
        })
#endif
    }
    
}
