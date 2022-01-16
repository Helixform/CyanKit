//
//  Created by ktiays on 2022/1/16.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import SwiftUI
import Combine
import CyanExtensions

@available(macOS 12.0, *)
struct _PopupList<Content>: View where Content: StringProtocol {
    
    let contents: [Content]
    @Binding var selection: Content?
    
    @State private var highlighted: Content?
    
    private let mouseUpEventPublisher: AnyPublisher<NSPoint, Never>
    
    init(contents: [Content], selection: Binding<Content?>, mouseUpEventPublisher: AnyPublisher<NSPoint, Never>) {
        self.contents = contents.enumerated().filter { index, element in
            contents.firstIndex(of: element) == index
        }.map { $0.element }
        _selection = selection
        self.mouseUpEventPublisher = mouseUpEventPublisher
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(contents, id: \.self) { item in
                ZStack {
                    Color(nsColor: .labelColor)
                        .opacity(highlighted == item ? 0.04 : 0)
                        .cornerRadius(8)
                    HStack {
                        Circle()
                            .frame(width: 6)
                            .foregroundColor(selection == item ? Color(nsColor: .labelColor) : .clear)
                        Text(item)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 36)
                    .padding(.vertical, 6)
                }
                .overlay {
                    _PopupItem(tag: item,
                               highlighted: $highlighted,
                               selection: $selection,
                               mouseUpEventPublisher: mouseUpEventPublisher)
                }
            }
        }
        .padding(4)
        .ignoresSafeArea()
        .background {
            VisualEffectView(material: .titlebar)
                .overlay {
                    Color(lightColor: .white, darkColor: .black).opacity(0.3)
                }
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.12), radius: 10)
        .padding()
    }
    
}

struct _PopupItem<S>: NSViewRepresentable where S: StringProtocol {
    
    let tag: S
    @Binding var highlighted: S?
    @Binding var selection: S?
    
    let mouseUpEventPublisher: AnyPublisher<NSPoint, Never>
    @State private var cancellable: AnyCancellable?
    
    func makeNSView(context: Context) -> _PopupItemView<S> {
        let view: _PopupItemView = .init(tag: tag, highlighted: $highlighted, selection: $selection)
        DispatchQueue.main.async {
            cancellable = mouseUpEventPublisher.sink {
                view.updateSelection(with: $0)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: _PopupItemView<S>, context: Context) { }
    
}

final class _PopupItemView<S>: NSView where S: StringProtocol {
    
    @Binding private var highlighted: S?
    @Binding private var selection: S?
    
    private let itemTag: S
    
    init(tag: S, highlighted: Binding<S?>, selection: Binding<S?>) {
        self.itemTag = tag
        _highlighted = highlighted
        _selection = selection
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var trackingArea: NSTrackingArea?
    
    override func layout() {
        super.layout()
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        highlighted = itemTag
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        if itemTag == highlighted {
            highlighted = nil
        }
    }
    
    func updateSelection(with mousePoint: NSPoint) {
        if let windowContentBounds = window?.contentView?.bounds {
            var itemFrame = convert(frame, to: window?.contentView)
            itemFrame.origin.y = windowContentBounds.height - itemFrame.minY - itemFrame.height
            if window?.convertToScreen(itemFrame).contains(mousePoint) == true {
                selection = itemTag
            }
        }
    }
    
}
