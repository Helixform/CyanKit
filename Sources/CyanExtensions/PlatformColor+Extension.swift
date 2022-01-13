//
//  Created by ktiays on 2021/5/2.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias PlatformColor = UIColor
#else
import AppKit
public typealias PlatformColor = NSColor
#endif

public extension PlatformColor {
    
    #if os(macOS)
    static var label: PlatformColor {
        return .labelColor
    }
    #endif
    
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
