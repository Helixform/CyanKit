//
//  Created by ktiays on 2021/5/2.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit
public typealias PlatformColor = UIColor

public extension PlatformColor {
    
    /// A color that reflects the accent color of the system or app.
    ///
    /// The accent color is a broad theme color applied to views and controls.
    /// You can set it at the application level by specifying an accent color in your app’s asset catalog.
    static let accentColor: UIColor? = .init(named: "AccentColor")
    
    convenience init(lightColor: PlatformColor, darkColor: PlatformColor) {
        self.init(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return lightColor
            }
        })
    }
    
    convenience init(integalRed: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: max(0, min(CGFloat(integalRed) / 255, 1)),
                  green: max(0, min(CGFloat(green) / 255, 1)),
                  blue: max(0, min(CGFloat(blue) / 255, 1)),
                  alpha: alpha)
    }
    
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init()
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

#elseif canImport(AppKit)

import AppKit
public typealias PlatformColor = NSColor

public extension PlatformColor {
    
    convenience init(lightColor: PlatformColor, darkColor: PlatformColor) {
        self.init(name: nil, dynamicProvider: { appearance in
            if appearance.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return lightColor
            }
        })
    }
    
    convenience init(integalRed: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: max(0, min(CGFloat(integalRed) / 255, 1)),
                  green: max(0, min(CGFloat(green) / 255, 1)),
                  blue: max(0, min(CGFloat(blue) / 255, 1)),
                  alpha: alpha)
    }
    
}

public extension PlatformColor {
    
    /// The primary color to use for text labels.
    ///
    /// Use this color in the most important text labels of your user interface.
    /// You can also use it for other types of primary app content.
    ///
    /// This color is the same as `labelColor`.
    static let label: NSColor = .labelColor
    
    /// The color to use for separators between different sections of content.
    ///
    /// Do not use this color for split view dividers or window chrome dividers.
    ///
    /// This color is the same as `separatorColor`.
    static let separator: NSColor = .separatorColor
    
}

#endif
