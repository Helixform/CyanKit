//
//  Created by ktiays on 2021/5/2.
//  Copyright (c) 2021 ktiays. All rights reserved.
//  

import SwiftUI

fileprivate let textColor = PlatformColor(lightColor: #colorLiteral(red: 0.368627451, green: 0.3843137255, blue: 0.4470588235, alpha: 1), darkColor: #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5333333333, alpha: 1))
fileprivate let selectedTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
fileprivate let defaultSelectedBackgroundColor = PlatformColor.systemBlue // #colorLiteral(red: 0.1411764706, green: 0.4196078431, blue: 0.9921568627, alpha: 1)

public struct SegmentedControl<SelectionValue, Content>: View where Content: RandomAccessCollection, Content.Element: SegmentedControlItem, SelectionValue == Content.Element.ID {
    
    private struct _FramePreference: PreferenceKey {
       
        typealias Value = [SelectionValue : Anchor<CGRect>]
        
        static var defaultValue: [SelectionValue : Anchor<CGRect>] { [:] }
        
        static func reduce(value: inout [SelectionValue : Anchor<CGRect>], nextValue: () -> [SelectionValue : Anchor<CGRect>]) {
            for pair in nextValue() {
                value[pair.key] = pair.value
            }
        }
        
    }
    
    let selection: Binding<SelectionValue>
    let content: Content
    var scrollable: Bool
    
    @Environment(\.selectedBackgroundColor) var selectedBackgroundColor: Color?
    
    public init(selection: Binding<SelectionValue>, content: Content, scrollable: Bool = false) {
        self.content = content
        self.selection = selection
        self.scrollable = scrollable
    }
    
    private func _backgroundView(with anchorInfo: _FramePreference.Value, color: Color = .black) -> some View {
        var selectedFrame: Anchor<CGRect>!
        for pair in anchorInfo {
            if pair.key == selection.wrappedValue {
                selectedFrame = pair.value
            }
        }
        
        return GeometryReader { proxy in
            Capsule()
                .size(width: proxy[selectedFrame].width, height: proxy[selectedFrame].height)
                .fill(color)
                .offset(x: proxy[selectedFrame].minX, y: 0)
        }
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(scrollable ? .horizontal : [], showsIndicators: false) {
                HStack {
                    ForEach(content) { item in
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 300.0, damping: 30)) {
                                selection.wrappedValue = item.id
                            }
                        }, label: {
                            Text(item.text)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(textColor))
                                .frame(height: 24)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(
                                    Color.clear
                                        .anchorPreference(key: _FramePreference.self,
                                                          value: .bounds) { [item.id: $0] }
                                )
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .id(item.id)
                    }
                }
                .onChange(of: selection.wrappedValue, perform: { value in
                    withAnimation(.spring()) {
                        proxy.scrollTo(value)
                    }
                })
                .overlayPreferenceValue(_FramePreference.self) { value in
                    _backgroundView(with: value, color: Color(selectedTextColor))
                        .blendMode(.sourceAtop)
                }
                .compositingGroup()
                .backgroundPreferenceValue(_FramePreference.self) { value in
                    _backgroundView(with: value, color: selectedBackgroundColor ?? Color(defaultSelectedBackgroundColor))
                }
            }
        }
    }
    
}

public protocol SegmentedControlItem: Identifiable {
    
    associatedtype ID = Hashable & Equatable
    
    var text: String { get }
    
}

public extension EnvironmentValues {
    var selectedBackgroundColor: Color? {
        get { self[_SelectedBackgroundColorEnvironmentKey.self] }
        set { self[_SelectedBackgroundColorEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    func selectedBackgroundColor(_ color: Color?) -> some View {
        return environment(\.selectedBackgroundColor, color)
    }
    
}

fileprivate struct _SelectedBackgroundColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color? { nil }
}

// MARK: - Preview

struct SegmentedControl_Previews: PreviewProvider {
    
    struct Item: SegmentedControlItem {
        
        typealias ID = Int
        
        var id: Int
        var text: String
        
    }
    
    private struct PreviewView: View {
        
        @State var selection: Int = 0
        
        let content: [Item] = [
            Item(id: 0, text: "Overview"),
            Item(id: 1, text: "Productivity"),
            Item(id: 2, text: "Cart"),
        ]
        
        var body: some View {
            SegmentedControl(selection: $selection, content: content, scrollable: true)
                .selectedBackgroundColor(Color(.orange))
        }
        
    }
    
    static var previews: some View {
        PreviewView()
    }
}
