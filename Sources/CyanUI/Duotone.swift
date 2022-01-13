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
    public let secondaryColor: Color
}

@available(iOS 15.0, macOS 12.0, *)
public struct IconColorConfigurationKey: EnvironmentKey {
    public static var defaultValue: IconColorConfiguration? {
        .init(primaryColor: .init(lightColor: .label, darkColor: .white),
              secondaryColor: .white.opacity(0.5))
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
                if let secondaryColor = iconColorConfiguration?.secondaryColor {
                    context.fill(.init(.init(origin: .zero, size: size)), with: .color(secondaryColor))
                    context.blendMode = .destinationIn
                }
                context.drawLayer { context in
                    style.makeSecondaryShape(configuration: .init(context: context, bounds: .init(origin: .zero, size: size), isHighlighted: isHighlighted))
                }
            }
            context.drawLayer { context in
                if let primaryColor = iconColorConfiguration?.primaryColor {
                    context.fill(.init(.init(origin: .zero, size: size)), with: .color(primaryColor))
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
