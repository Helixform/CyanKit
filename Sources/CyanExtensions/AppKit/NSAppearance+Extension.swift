//
//  Created by Cyandev on 2022/3/31.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

#if canImport(AppKit)

import AppKit

public enum UserInterfaceStyle {
    case light
    case dark
}

public extension NSAppearance {
    
    var userInterfaceStyle: UserInterfaceStyle {
        if name == Name.darkAqua ||
            name == Name.vibrantDark ||
            name == Name.accessibilityHighContrastDarkAqua ||
            name == Name.accessibilityHighContrastVibrantDark {
            return .dark
        }
        return .light
    }
    
}

#endif
