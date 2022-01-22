//
//  Created by Cyandev on 2022/1/22.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

import SwiftUI

public struct AnimatedClickableConfiguration {
    
    public var activeAnimation: Animation
    public var identityAnimation: Animation
    
    public private(set) var activeModifier: AnyViewModifier
    public private(set) var identityModifier: AnyViewModifier
    
    /// A default configuration with spring animation and highlight effect.
    public static let highlight = Self.empty().activeOpacity(0.3)
    
    /// An empty configuration with the given animations, which has no active effects.
    public static func empty(
        activeAnimation: Animation = .spring(response: 0.1),
        identityAnimation: Animation = .spring(response: 0.6)
    ) -> Self {
        return .init(
            activeAnimation: activeAnimation,
            identityAnimation: identityAnimation,
            activeModifier: .init(),
            identityModifier: .init()
        )
    }
    
    public func combined<E>(with modifierBuilder: (_ active: Bool) -> E) -> Self where E: ViewModifier {
        var copy = self
        copy.activeModifier = copy.activeModifier.typeErasedConcat(modifierBuilder(true))
        copy.identityModifier = copy.identityModifier.typeErasedConcat(modifierBuilder(false))
        return copy
    }
    
    public func activeScale(_ scale: CGFloat) -> Self {
        combined { active in
            AnyViewModifier { $0.scaleEffect(active ? scale : 1) }
        }
    }
    
    public func activeOpacity(_ opacity: CGFloat) -> Self {
        combined { active in
            AnyViewModifier {
                $0.compositingGroup()
                    .opacity(active ? opacity : 1)
            }
        }
    }
    
}

public struct AnimatedClickableModifier: ViewModifier {
    
    public let configuration: AnimatedClickableConfiguration
    public let action: () -> ()
    
    public init(configuration: AnimatedClickableConfiguration, action: @escaping () -> ()) {
        self.configuration = configuration
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        _AnimatedClickableView(content, configuration: configuration, action: action)
    }
    
}

public extension View {
    
    func animatedClickable(
        configuration: AnimatedClickableConfiguration = .highlight,
        action: @escaping () -> ()
    ) -> some View {
        modifier(AnimatedClickableModifier(configuration: configuration, action: action))
    }
    
}

private struct _AnimatedClickableView<V>: View where V: View {
    
    private let content: V
    private let configuration: AnimatedClickableConfiguration
    private let action: () -> ()

    @State private var viewSize: CGSize = .zero
    @State private var isPressed: Bool = false
    @State private var isPointInside: Bool = false
    
    init(_ content: V, configuration: AnimatedClickableConfiguration, action: @escaping () -> ()) {
        self.content = content
        self.configuration = configuration
        self.action = action
    }
    
    var body: some View {
        content
            .overlay(sizeReader())
            .modifier(isPointInside
                ? configuration.activeModifier
                : configuration.identityModifier)
            .highPriorityGesture(dragGesture())
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                withAnimation(isPressed
                              ? configuration.identityAnimation
                              : configuration.activeAnimation) {
                    let activeZone = CGRect(origin: .zero, size: viewSize)
                        .insetBy(dx: -24, dy: -24)
                    isPointInside = activeZone.contains(value.location)
                }
                isPressed = true
            }
            .onEnded { _ in
                if isPointInside {
                    action()
                }
                withAnimation(configuration.identityAnimation) {
                    isPressed = false
                    isPointInside = false
                }
            }
    }
    
    private func sizeReader() -> some View {
        GeometryReader { proxy in
            Color.clear
                .onChange(of: proxy.size) { newValue in
                    viewSize = newValue
                }
                .onAppear {
                    viewSize = proxy.size
                }
        }
    }
    
}
