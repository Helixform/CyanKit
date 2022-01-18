//
//  Created by ktiays on 2022/1/13.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public protocol DuotoneIconStyle {
    
    typealias Configuration = DuotoneIconConfiguration
    
    func makePrimaryShape(configuration: Self.Configuration)
    
    func makeSecondaryShape(configuration: Self.Configuration)
    
}

@available(iOS 15.0, macOS 12.0, *)
public struct DuotoneIconConfiguration {
    public let context: GraphicsContext
    public let bounds: CGRect
    public let isHighlighted: Bool
}

@available(iOS 15.0, macOS 12.0, *)
public struct IconColorConfiguration {
    public let primaryColor: Color
    public let highlightPrimaryColor: Color
    public let secondaryColor: Color
    public let highlightSecondaryColor: Color
}

@available(iOS 15.0, macOS 12.0, *)
public struct IconColorConfigurationKey: EnvironmentKey {
    public static var defaultValue: IconColorConfiguration? {
        let primaryColor: Color = .init(lightColor: .label, darkColor: .white)
        let secondaryColor: Color = .white.opacity(0.5)
        return .init(primaryColor: primaryColor, highlightPrimaryColor: primaryColor,
                     secondaryColor: secondaryColor, highlightSecondaryColor: secondaryColor)
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension EnvironmentValues {
    var iconColorConfiguration: IconColorConfiguration? {
        get { self[IconColorConfigurationKey.self] }
        set { self[IconColorConfigurationKey.self] = newValue }
    }
}

@available(iOS 15.0, macOS 12.0, *)
public struct DuotoneIcon<S>: View where S: DuotoneIconStyle {
    
    @Environment(\.iconColorConfiguration) var iconColorConfiguration
    
    private let style: S
    
    @Binding private var isHighlighted: Bool
    
    public init(_ style: S, isHighlighted: Binding<Bool>) {
        self.style = style
        _isHighlighted = isHighlighted
    }
    
    public var body: some View {
        Canvas { context, size in
            context.drawLayer { context in
                if let secondaryColor = iconColorConfiguration?.secondaryColor,
                   let hightlightSecondaryColor = iconColorConfiguration?.highlightSecondaryColor {
                    context.fill(.init(.init(origin: .zero, size: size)), with: .color(isHighlighted ? hightlightSecondaryColor : secondaryColor))
                    context.blendMode = .destinationIn
                }
                context.drawLayer { context in
                    style.makeSecondaryShape(configuration: .init(context: context, bounds: .init(origin: .zero, size: size), isHighlighted: isHighlighted))
                }
            }
            context.drawLayer { context in
                if let primaryColor = iconColorConfiguration?.primaryColor,
                   let hightlightPrimaryColor = iconColorConfiguration?.highlightPrimaryColor {
                    context.fill(.init(.init(origin: .zero, size: size)), with: .color(isHighlighted ? hightlightPrimaryColor : primaryColor))
                    context.blendMode = .destinationIn
                }
                context.drawLayer { context in
                    style.makePrimaryShape(configuration: .init(context: context, bounds: .init(origin: .zero, size: size), isHighlighted: isHighlighted))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    public func multicolor() -> some View {
        environment(\.iconColorConfiguration, nil)
    }
    
}
