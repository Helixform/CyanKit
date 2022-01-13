import SwiftUI

public struct ContinuousCapsule: Shape {
    
    public init() {}
    
    public func path(in rect: CGRect) -> Path {
        RoundedRectangle(
            cornerRadius: min(rect.width, rect.height) / 2,
            style: .continuous
        ).path(in: rect)
    }
    
}

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

public extension View {
    
    func hideListRowSeparator() -> some View {
        #if os(iOS)
        listRowSeparator(.hidden)
        #else
        self
        #endif
    }
    
}
