//
//  Created by Cyandev on 2022/1/14.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import SwiftUI

// MARK: Color

public extension Color {
    
    init(platformColor: PlatformColor) {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            self.init(uiColor: platformColor)
        } else {
            self.init(platformColor)
        }
        #else
        if #available(macOS 12.0, *) {
            self.init(nsColor: platformColor)
        } else {
            self.init(platformColor)
        }
        #endif
    }
    
    @inlinable init(lightColor: PlatformColor, darkColor: PlatformColor) {
        self.init(platformColor: .init(lightColor: lightColor, darkColor: darkColor))
    }
    
}

public extension Color {
    
    /// A context-dependent red color that automatically adapts to the current trait environment.
    static let systemRed: Color = .init(platformColor: .systemRed)
    
    /// A context-dependent orange color that automatically adapts to the current trait environment.
    static let systemOrange: Color = .init(platformColor: .systemOrange)
    
    /// A context-dependent yellow color that automatically adapts to the current trait environment.
    static let systemYellow: Color = .init(platformColor: .systemYellow)
    
    /// A context-dependent green color that automatically adapts to the current trait environment.
    static let systemGreen: Color = .init(platformColor: .systemGreen)
    
    /// A context-dependent blue color that automatically adapts to the current trait environment.
    static let systemBlue: Color = .init(platformColor: .systemBlue)
    
    /// A context-dependent indigo color that automatically adapts to the current trait environment.
    static let systemIndigo: Color = .init(platformColor: .systemIndigo)
    
    /// A context-dependent purple color that automatically adapts to the current trait environment.
    static let systemPurple: Color = .init(platformColor: .systemPurple)
    
    /// A context-dependent pink color that automatically adapts to the current trait environment.
    static let systemPink: Color = .init(platformColor: .systemPink)
    
    /// A context-dependent teal color that automatically adapts to the current trait environment.
    static let systemTeal: Color = .init(platformColor: .systemTeal)
    
    /// A context-dependent cyan color that automatically adapts to the current trait environment.
    @available(iOS 15.0, macOS 12.0, *)
    static let systemCyan: Color = .init(platformColor: .systemCyan)
    
    /// A context-dependent mint color that automatically adapts to the current trait environment.
    static let systemMint: Color = .init(platformColor: .systemMint)
    
    /// A context-dependent gray color that automatically adapts to the current trait environment.
    static let systemGray: Color = .init(platformColor: .systemGray)
    
}

// MARK: - View

public extension View {
    
    func hideListRowSeparator() -> some View {
        #if os(iOS)
        Group {
            if #available(iOS 15.0, *) {
                listRowSeparator(.hidden)
            } else {
                self
            }
        }
        #else
        self
        #endif
    }
    
}

// MARK: - EdgeInsets

public extension EdgeInsets {
    
    /// An edge insets struct whose top, left, bottom, and right fields are all set to 0.
    static let zero: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
}
