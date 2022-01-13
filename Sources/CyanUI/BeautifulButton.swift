//
//  Created by ktiays on 2021/11/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

public struct BeautifulButton: View {
    
    public let text: String
    public let action: () -> ()
    
    public enum Style {
        case fill
        case bordered
    }
    
    private let style: Style
    private let cornerRadius: CGFloat
    
    @State private var pressed: Bool = false
    @State private var buttonSize: CGSize = .zero
    
    public init(text: String, action: @escaping () -> (), style: Style = .fill, cornerRadius: CGFloat = 12) {
        self.text = text
        self.action = action
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    private let systemBlueColor: Color = .init(platformColor: .systemBlue)
    
    private var textColor: Color {
        switch style {
        case .fill:
            return .white
        case .bordered:
            return systemBlueColor.opacity(pressed ? 0.3 : 1)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .fill:
            return systemBlueColor
        case .bordered:
            return textColor
        }
    }
    
    private var scaleRatio: CGFloat {
        switch style {
        case .fill:
            return pressed ? 0.9 : 1.0
        case .bordered:
            return 1.0
        }
    }
    
    public var body: some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Group {
                    switch style {
                    case .fill:
                        backgroundColor
                    case .bordered:
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(lineWidth: 2)
                            .foregroundColor(backgroundColor)
                    }
                }
            )
            .overlay(
                GeometryReader { proxy in
                    Color(white: 0, opacity: (pressed && style == .fill) ? 0.3 : 0)
                        .onChange(of: proxy.size) { newValue in
                            buttonSize = proxy.size
                        }
                        .onAppear {
                            buttonSize = proxy.size
                        }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(scaleRatio, anchor: .center)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        withAnimation(.spring(response: 0.2)) {
                            pressed = CGRect(origin: .zero, size: buttonSize).contains(value.location)
                        }
                    })
                    .onEnded({ value in
                        if pressed {
                            action()
                        }
                        withAnimation(.spring(response: 0.35)) {
                            pressed = false
                        }
                    })
            )
    }
    
    public func buttonStyle(_ style: Style) -> BeautifulButton {
        .init(text: text, action: action, style: style, cornerRadius: cornerRadius)
    }
    
    public func cornerRadius(_ radius: CGFloat) -> BeautifulButton {
        .init(text: text, action: action, style: style, cornerRadius: radius)
    }
    
}

public struct RoundedBorderedButtonStyle: ButtonStyle {
    
    private let lineWidth: CGFloat
    private let cornerRadius: CGFloat
    private let borderColor: Color
    
    public init(lineWidth: CGFloat = 1, cornerRadius: CGFloat = 12, borderColor: Color = Color(platformColor: .label)) {
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(borderColor)
            )
            .opacity(configuration.isPressed ? 0.3 : 1)
    }
    
}

public extension ButtonStyle where Self == RoundedBorderedButtonStyle {
    
    static var roundedBordered: RoundedBorderedButtonStyle { .init() }
    
}
