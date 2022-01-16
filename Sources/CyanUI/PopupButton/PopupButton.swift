//
//  Created by ktiays on 2022/1/15.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import SwiftUI
import AppKit
import ObjectiveC
import CyanUtils
import Combine

@available(macOS 12.0, *)
public struct PopupButton<S>: View where S: StringProtocol {
    
    public let contents: [S]
    
    @Binding public var selection: S?
    
    public init(contents: [S], selection: Binding<S?>) {
        self.contents = contents
        _selection = selection
    }
    
    public var body: some View {
        HStack {
            Text(selection ?? "")
                .padding(.trailing, 48)
        }
        .background(Color.systemBlue.opacity(0.3))
        .overlay(_PopupButtonTrigger(contents: contents, selection: $selection))
    }
    
}

// MARK: - Trigger

@available(macOS 12.0, *)
struct _PopupButtonTrigger<S>: NSViewRepresentable where S: StringProtocol {
    
    let contents: [S]
    @Binding var selection: S?
    
    func makeNSView(context: Context) -> _PopupButtonTriggerView<S> {
        .init(selection: $selection)
    }
    
    func updateNSView(_ nsView: _PopupButtonTriggerView<S>, context: Context) {
        nsView.reloadDataSource(contents)
    }
    
}

@available(macOS 12.0, *)
class _PopupButtonTriggerView<S>: NSView where S: StringProtocol {
    
    private var popupListContent: [S] = []
    @Binding private var selection: S?
    
    private var localMonitor: Any?
    private var globalMonitor: Any?
    
    private weak var popupWindow: NSWindow?
    private var isPresented: Bool { popupWindow != nil }
    
    private let mouseUpSubject: PassthroughSubject<NSPoint, Never> = .init()
    
    init(selection: Binding<S?>) {
        _selection = selection
        super.init(frame: .zero)
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .leftMouseDown]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .leftMouseDown]) { [weak self] event in
            self?.handleMouseEvent(event)
        }
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            if let window = popupWindow {
                let mouseLocation = window.convertPoint(toScreen: event.locationInWindow)
                if !window.frame.contains(mouseLocation) {
//                    removePopupWindow()
                }
            }
        case .leftMouseUp:
            mouseUpSubject.send(NSEvent.mouseLocation)
        default: break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let localMonitor = localMonitor, let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(localMonitor)
            NSEvent.removeMonitor(globalMonitor)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if isPresented { return }
        
        let window = NSWindow(contentViewController: NSHostingController(rootView: _PopupList(contents: popupListContent, selection: $selection, mouseUpEventPublisher: mouseUpSubject.eraseToAnyPublisher())))
        window.isReleasedWhenClosed = false
        window.styleMask = .borderless
        window.hasShadow = false
        window.backgroundColor = .clear
        self.window?.addChildWindow(window, ordered: .above)
        window.contentView?.layout()
        let contentSize = window.contentView?.fittingSize ?? .zero
        let location = NSEvent.mouseLocation
        window.setFrame(.init(origin: location, size: .init(width: max(contentSize.width, bounds.width + 20), height: contentSize.height)), display: true)
        
        popupWindow = window
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
    }
    
    private func removePopupWindow() {
        if let window = popupWindow {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.4
                window.animator().alphaValue = 0
            } completionHandler: {
                window.close()
            }
        }
    }
    
    func reloadDataSource(_ dataSource: [S]) {
        self.popupListContent = dataSource
    }
    
}
