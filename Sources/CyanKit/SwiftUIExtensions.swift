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
