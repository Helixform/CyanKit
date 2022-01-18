//
//  Created by ktiays on 2022/1/15.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#if os(macOS)

import SwiftUI
import AppKit
import ObjectiveC
import CyanUtils
import Combine

@available(macOS 12.0, *)
public struct PopupButton<S>: View where S: StringProtocol {
    
    public let contents: [S]
    
    @Binding public var selection: S?
    
    private let backgroundColor: Color
    
    public init(contents: [S], selection: Binding<S?>) {
        self.init(contents: contents, selection: selection, backgroundColor: .secondary)
    }
    
    private init(contents: [S], selection: Binding<S?>, backgroundColor: Color) {
        self.contents = contents
        _selection = selection
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        HStack {
            Text(selection ?? "")
                .padding(.trailing, 12)
            Spacer()
            // Draw a rounded corner triangle.
            CGSize(width: 25, height: 25) |> { size in
                CGSize(width: 8, height: 4) |> { triangleSize in
                    Path { path in
                        let origin = CGPoint(x: (size.width - triangleSize.width) / 2, y: (size.height - triangleSize.height) / 2)
                        path.move(to: origin)
                        path.addLine(to: .init(x: origin.x + triangleSize.width, y: origin.y))
                        path.addLine(to: .init(x: origin.x + triangleSize.width / 2, y: origin.y + triangleSize.height))
                        path.closeSubpath()
                    } |> { trianglePath in
                        Color(nsColor: .init(lightColor: .init(red: 30.0 / 255, green: 30.0 / 255, blue: 30.0 / 255, alpha: 1),
                                             darkColor: .init(red: 212.0 / 255, green: 212.0 / 255, blue: 212.0 / 255, alpha: 1))) |> { foregroundColor in
                            ZStack {
                                trianglePath.fill(foregroundColor)
                                trianglePath.stroke(foregroundColor, style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: size.width)
                        }
                    }
                }
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 4)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(_PopupButtonTrigger(contents: contents, selection: $selection))
    }
    
    public func backgroundColor(_ color: Color) -> PopupButton {
        .init(contents: self.contents, selection: _selection, backgroundColor: color)
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
        nsView.popupListContent = contents
    }
    
}

@available(macOS 12.0, *)
class _PopupButtonTriggerView<S>: NSView where S: StringProtocol {
    
    /// The contents that acts as the data source of the pop-up menu.
    var popupListContent: [S] = [] {
        didSet {
            reloadContent()
        }
    }
    @Binding private var selection: S?
    
    private var currentSelectedIndex: Int? {
        if let selection = selection {
            return popupListContent.firstIndex(of: selection)
        }
        return nil
    }
    
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
    
    /// The position where the mouse click when the menu pops up.
    private var presentedPoint: NSPoint?
    
    private func handleMouseEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            if let window = popupWindow {
                let mouseLocation = window.convertPoint(toScreen: event.locationInWindow)
                if !window.frame.contains(mouseLocation) {
                    removePopupWindow()
                }
            }
        case .leftMouseUp:
            if popupWindow == nil { return }
            let currentMouseLocation = NSEvent.mouseLocation
            if let presentedPoint = presentedPoint {
                if !presentedPoint.nearBy(currentMouseLocation) {
                    removePopupWindow()
                } else { return }
            } else {
                removePopupWindow()
            }
            mouseUpSubject.send(currentMouseLocation)
        default: break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
    }
    
    private let menuPadding: CGFloat = 16
    private let menuInnerPadding: CGFloat = 4
    private let menuItemHeight: CGFloat = 28
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if isPresented { return }
        
        let window = NSWindow(contentViewController: NSHostingController(rootView: _PopupList(contents: popupListContent, selection: _selection, mouseUpEventPublisher: mouseUpSubject.eraseToAnyPublisher())))
        window.isReleasedWhenClosed = false
        window.styleMask = .borderless
        window.hasShadow = false
        window.backgroundColor = .clear
        self.window?.addChildWindow(window, ordered: .above)
        
        updateWindow(window)
        
        popupWindow = window
        
        // Save the location of the click that triggered the menu popup.
        presentedPoint = NSEvent.mouseLocation
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(280)) { [weak self] in
            self?.presentedPoint = nil
        }
    }
    
    private func removePopupWindow() {
        if let window = popupWindow {
            window.ignoresMouseEvents = true
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.4
                window.animator().alphaValue = 0
                popupWindow = nil
            } completionHandler: {
                window.close()
            }
        }
    }
    
    private func updateWindow(_ window: NSWindow) {
        window.contentView?.layout()
        let contentSize = window.contentView?.fittingSize ?? .zero
        
        if let frameFromWindow = self.window?.convertToScreen(convert(frame, to: nil)) {
            window.setFrame(.init(x: frameFromWindow.minX - menuPadding - menuInnerPadding,
                                  y: frameFromWindow.minY + frameFromWindow.height / 2 - menuPadding - menuInnerPadding - menuItemHeight * (max(popupListContent.count, 1) - (currentSelectedIndex ?? 0) - 0.5),
                                  width: max(contentSize.width, bounds.width + (menuPadding + menuInnerPadding) * 2),
                                  height: contentSize.height),
                            display: true)
        }
    }
    
    private func reloadContent() {
        guard let window = popupWindow else {
            return
        }
        if let controller = window.contentViewController as? NSHostingController<_PopupList<S>> {
            controller.rootView = .init(
                contents: popupListContent,
                selection: _selection,
                mouseUpEventPublisher: mouseUpSubject.eraseToAnyPublisher()
            )
            updateWindow(window)
        }
    }
    
}

#endif
