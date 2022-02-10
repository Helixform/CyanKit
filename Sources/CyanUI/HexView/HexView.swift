//
//  Created by Cyandev on 2022/2/10.
//  Copyright © 2022 Cyandev. All rights reserved.
//

#if os(macOS)

import Cocoa

public class HexView: NSView {
    
    public override var isFlipped: Bool {
        return true
    }
    
    private var viewportBounds: NSRect {
        guard let clipView = enclosingScrollView?.contentView else {
            return bounds
        }
        return clipView.bounds.insetBy(dx: 0, dy: -64)
    }
    
    private var totalLines: Int {
        return Int(ceil(Double((dataProvider?.length ?? 0)) / Double(drawingHelper.octetsPerLine)))
    }
    
    private var drawingHelper = HexViewDrawingHelper()
    private weak var cursorBlinkTimer: Timer?
    
    private var visualSelectionStart: HexViewDrawingHelper.Position?
    private var visualSelectionEnd: HexViewDrawingHelper.Position?
    private var componentUnderCursor: HexViewDrawingHelper.ComponentType = .hex
    private var isMouseDragging = false
    private var cursorBlinkState = false
    
    private var specialCharacterColor = NSColor.systemRed.withAlphaComponent(0.5)
    
    public var dataProvider: HexViewDataProvider? {
        didSet {
            reloadData()
        }
    }
    
    deinit {
        cursorBlinkTimer?.invalidate()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        drawingHelper.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        drawingHelper.selectionFillColor = NSColor.selectedTextBackgroundColor.withAlphaComponent(0.4)
        drawingHelper.selectionStrokeColor = NSColor.selectedTextBackgroundColor
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleViewportChange(_:)),
                                               name: NSView.frameDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleViewportChange(_:)),
                                               name: NSView.boundsDidChangeNotification,
                                               object: nil)
    }
    
    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        if let scrollView = (superview as? NSClipView)?.enclosingScrollView {
            scrollView.scroll(.zero)
        }
    }
    
    public override func layout() {
        super.layout()
        
        let newFrame = CGRect(
            x: 0, y: 0,
            width: superview!.frame.width, height: ceil(CGFloat(totalLines) * drawingHelper.lineHeight)
        )
        frame = newFrame
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        // Gather drawing informations.
        let gutterWidth = drawingHelper.gutterWidth
        let lineHeight = drawingHelper.lineHeight
        let charWidth = drawingHelper.charWidth
        
        let octetsPerLine = drawingHelper.octetsPerLine
        
        let viewportBounds = self.viewportBounds
        let lowerBounds = max(Int(floor(viewportBounds.minY / lineHeight)), 0)
        let upperBounds = min(Int(ceil(viewportBounds.maxY / lineHeight)), totalLines)
        
        // Draw alternative backgrounds.
        context.setFillColor(NSColor.textColor.withAlphaComponent(0.04).cgColor)
        for i in lowerBounds..<upperBounds {
            if i % 2 != 0 {
                NSBezierPath(rect: .init(x: 0, y: CGFloat(i) * lineHeight,
                                         width: viewportBounds.width, height: lineHeight)).fill()
            }
        }
        
        // Draw selections.
        if let visualSelectionStart = self.visualSelectionStart, let visualSelectionEnd = self.visualSelectionEnd {
            let widthOfHexArea =
                charWidth * CGFloat(type(of: drawingHelper).numberOfLineCharacters(for: octetsPerLine))
            let gapBetweenAreas = charWidth * 2
            
            drawingHelper.drawSelection(
                from: drawingHelper.origin(of: .hex, at: min(visualSelectionStart, visualSelectionEnd)),
                to: drawingHelper.origin(of: .hex, at: max(visualSelectionStart, visualSelectionEnd)),
                stride: 2,
                drawingBounds: .init(x: gutterWidth, y: 0, width: widthOfHexArea, height: viewportBounds.height),
                in: context
            )
            
            drawingHelper.drawSelection(
                from: drawingHelper.origin(of: .ascii, at: min(visualSelectionStart, visualSelectionEnd)),
                to: drawingHelper.origin(of: .ascii, at: max(visualSelectionStart, visualSelectionEnd)),
                stride: 1,
                drawingBounds: .init(x: gutterWidth + widthOfHexArea + gapBetweenAreas, y: 0,
                                     width: charWidth * CGFloat(octetsPerLine), height: viewportBounds.height),
                in: context
            )
        }
        
        // Draw cursor.
        if let visualSelectionEnd = self.visualSelectionEnd, !cursorBlinkState {
            context.setFillColor(NSColor.selectedTextBackgroundColor.cgColor)
            let cursorPath = NSBezierPath(
                rect: .init(origin: drawingHelper.origin(of: componentUnderCursor, at: visualSelectionEnd),
                            size: .init(width: charWidth * CGFloat(componentUnderCursor.stride), height: lineHeight))
            )
            
            cursorPath.fill()
            cursorPath.stroke()
        }
        
        // Draw lines.
        let charVerticalAdjust = -drawingHelper.charDrawingOriginY + (lineHeight - drawingHelper.charHeight) / 2
        for i in lowerBounds..<min(upperBounds, totalLines) {
            let lineContent = content(for: i)
            lineContent.draw(at: .init(x: gutterWidth, y: CGFloat(i) * lineHeight + charVerticalAdjust))
            
            let address = String(hexStringWith: i * octetsPerLine, uppercase: true, paddingTo: 8)
            (address as NSString).draw(
                at: .init(x: 4, y: CGFloat(i) * lineHeight + charVerticalAdjust),
                withAttributes: [
                    NSAttributedString.Key.font: drawingHelper.font!,
                    NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
                ]
            )
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let hitComponent = drawingHelper.hitTest(at: point) {
            visualSelectionStart = clampCursorPosition(hitComponent.1)
            visualSelectionEnd = visualSelectionStart
            componentUnderCursor = hitComponent.0
            isMouseDragging = true
            
            setNeedsDisplay(viewportBounds)
            startCursorBlinking()
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        guard isMouseDragging else {
            return
        }
        
        autoscroll(with: event)
        
        // Stop cursor blinking, we want the cursor to be visible while selecting.
        cursorBlinkState = false
        cursorBlinkTimer?.invalidate()
        
        let point = convert(event.locationInWindow, from: nil)
        if let hitComponent = drawingHelper.hitTest(at: point) {
            visualSelectionEnd = clampCursorPosition(hitComponent.1)
            componentUnderCursor = hitComponent.0
            
            setNeedsDisplay(viewportBounds)
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        isMouseDragging = false
        
        startCursorBlinking()
    }
    
    @objc private func handleViewportChange(_ note: NSNotification) {
        guard note.object as? NSView === superview else {
            return
        }
        setNeedsDisplay(viewportBounds)
    }
    
    private func reloadData() {
        needsLayout = true
        setNeedsDisplay(viewportBounds)
    }
    
    private func content(for line: Int) -> NSAttributedString {
        guard let dataProvider = self.dataProvider else {
            return .init()
        }
        
        let length = dataProvider.length
        let start = drawingHelper.dataIndex(at: .init(line: line, column: 0))
        let end = drawingHelper.dataIndex(at: .init(line: line, column: drawingHelper.octetsPerLine - 1))
        
        var specialIndexes = IndexSet()
        let line = NSMutableAttributedString()
        for i in start...min(length - 1, end) {
            let byte = dataProvider.byte(at: i)
            if byte <= 15 {
                line.append(.init(string: "0"))
            }
            line.append(.init(string: .init(byte, radix: 16, uppercase: true)))
            
            // TODO: remove the hard-coded logic.
            if line.length == 23 || line.length == 48 {
                line.append(.init(string: "  "))
            } else {
                line.append(.init(string: " "))
            }
        }
        
        if line.length < 50 {
            line.append(.init(string: .init(repeating: " ", count: 50 - line.length)))
        }
        
        for i in start...min(length - 1, end) {
            let byte = dataProvider.byte(at: i)
            if byte < 32 || byte >= 127 {
                line.append(.init(string: "."))
                specialIndexes.insert(line.length - 1)
            } else {
                line.append(.init(string: .init(Character(UnicodeScalar(byte)))))
            }
        }
        
        var style: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: drawingHelper.font!,
            NSAttributedString.Key.foregroundColor: NSColor.textColor
        ]
        line.setAttributes(style, range: .init(location: 0, length: line.length))
        
        style[NSAttributedString.Key.foregroundColor] = specialCharacterColor
        for specialIndex in specialIndexes {
            line.setAttributes(style, range: .init(location: specialIndex, length: 1))
        }
        
        return line
    }
    
    private func clampCursorPosition(_ position: HexViewDrawingHelper.Position) -> HexViewDrawingHelper.Position {
        let line = min(max(position.line, 0), totalLines - 1)
        let column = min(max(position.column, 0), drawingHelper.octetsPerLine - 1)
        return .init(line: line, column: column)
    }
    
    private func startCursorBlinking() {
        if cursorBlinkTimer == nil {
            cursorBlinkTimer = .scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.cursorBlinkState.toggle()
                self.setNeedsDisplay(self.viewportBounds)
            }
        }
    }
    
}

#endif
