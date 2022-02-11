//
//  Created by Cyandev on 2022/2/10.
//  Copyright © 2022 Cyandev. All rights reserved.
//

#if os(macOS)

import Cocoa

/// A set of optional methods that hex view delegates can use to
/// manage selection, and more.
@objc public protocol HexViewDelegate: NSObjectProtocol {
    
    /// Tells the delegate when the selection has changed in the hex view.
    @objc optional func selectionDidChangeInHexView(_ view: HexView)
    
}

/// A view that allows inspecting large data in hex view.
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
    private var lineLayers = [_HexViewComponentLineLayer]()
    private var recyclePool = [_HexViewComponentLineLayer]()
    
    private var visualSelectionStart: HexViewDrawingHelper.Position?
    private var visualSelectionEnd: HexViewDrawingHelper.Position?
    private var componentUnderCursor: HexViewDrawingHelper.ComponentType = .hex
    private var isMouseDragging = false
    private var cursorBlinkState = false
    
    /// The data provider of the receiver’s content.
    public var dataProvider: HexViewDataProvider? {
        didSet {
            reloadData()
        }
    }
    
    /// The receiver’s delegate.
    public weak var delegate: HexViewDelegate?
    
    /// The range of bytes selected in the receiver.
    public var selectedRange: NSRange? {
        // No selections and inserting points.
        guard let visualSelectionEnd = visualSelectionEnd else {
            return nil
        }
        
        // Has inserting points but no selections.
        var dataSelectionEnd = drawingHelper.dataIndex(at: visualSelectionEnd)
        guard let visualSelectionStart = visualSelectionStart else {
            return .init(location: dataSelectionEnd, length: 1)
        }
        
        // Has selections.
        let selectionEnd = max(visualSelectionEnd, visualSelectionStart)
        let selectionStart = min(visualSelectionEnd, visualSelectionStart)
        dataSelectionEnd = drawingHelper.dataIndex(at: selectionEnd)
        let dataSelectionStart = drawingHelper.dataIndex(at: selectionStart)
        return .init(location: dataSelectionStart, length: dataSelectionEnd - dataSelectionStart + 1)
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
        wantsLayer = true
        
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
        
        enclosingScrollView?.scroll(.zero)
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
            let hexLineStartOrigin = drawingHelper.origin(of: .hex, at: .init(line: 0, column: 0))
            let hexLineEndOrigin = drawingHelper.origin(of: .hex, at: .init(line: 0, column: octetsPerLine))
            drawingHelper.drawSelection(
                from: drawingHelper.origin(of: .hex, at: min(visualSelectionStart, visualSelectionEnd)),
                to: drawingHelper.origin(of: .hex, at: max(visualSelectionStart, visualSelectionEnd)),
                stride: 2,
                drawingBounds: .init(x: hexLineStartOrigin.x, y: 0,
                                     width: hexLineEndOrigin.x - hexLineStartOrigin.x,
                                     height: viewportBounds.height),
                in: context
            )
            
            let asciiLineStartOrigin = drawingHelper.origin(of: .ascii, at: .init(line: 0, column: 0))
            drawingHelper.drawSelection(
                from: drawingHelper.origin(of: .ascii, at: min(visualSelectionStart, visualSelectionEnd)),
                to: drawingHelper.origin(of: .ascii, at: max(visualSelectionStart, visualSelectionEnd)),
                stride: 1,
                drawingBounds: .init(x: asciiLineStartOrigin.x, y: 0,
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
        
        // Draw address gutter.
        let charVerticalAdjust = -drawingHelper.charDrawingOriginY + (lineHeight - drawingHelper.charHeight) / 2
        for i in lowerBounds..<min(upperBounds, totalLines) {
            let address = String(hexStringWith: i * octetsPerLine, uppercase: true, paddingTo: 8)
            (address as NSString).draw(
                at: .init(x: 4, y: CGFloat(i) * lineHeight + charVerticalAdjust),
                withAttributes: [
                    NSAttributedString.Key.font: drawingHelper.font!,
                    NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
                ]
            )
        }
        
        // Draw double-word separator.
        for i in 0..<(octetsPerLine / 4 - 1) {
            let x = drawingHelper.origin(of: .hex, at: .init(line: 0, column: 4 * (i + 1))).x - charWidth / 2
            context.move(to: .init(x: x, y: viewportBounds.minY))
            context.addLine(to: .init(x: x, y: viewportBounds.maxY))
        }
        context.setStrokeColor(NSColor.textColor.withAlphaComponent(0.2).cgColor)
        context.strokePath()
        
        // Finally, arrange the content lines.
        layoutLines(from: lowerBounds, to: upperBounds)
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
            
            delegate?.selectionDidChangeInHexView?(self)
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
            let hitPosition = clampCursorPosition(hitComponent.1)
            guard hitPosition != visualSelectionEnd else {
                return
            }
            visualSelectionEnd = hitPosition
            componentUnderCursor = hitComponent.0
            
            setNeedsDisplay(viewportBounds)
            
            delegate?.selectionDidChangeInHexView?(self)
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
    
    private func layoutLines(from fromLine: Int, to toLine: Int) {
        // Make sure the line array is ordered.
        lineLayers.sort { lhs, rhs in
            return lhs.representingLine < rhs.representingLine
        }
        
        // First, remove all off-screen lines.
        while let firstLine = lineLayers.first {
            if firstLine.representingLine < fromLine {
                firstLine.removeFromSuperlayer()
                lineLayers.removeFirst()
                recyclePool.append(firstLine)
            } else {
                break
            }
        }
        while let lastLine = lineLayers.last {
            if lastLine.representingLine > toLine {
                lastLine.removeFromSuperlayer()
                lineLayers.removeLast()
                recyclePool.append(lastLine)
            } else {
                break
            }
        }
        
        let lineHeight = drawingHelper.lineHeight
        let viewportBounds = self.viewportBounds
        
        func addLineLayer(for line: Int, forwards: Bool = true) {
            let lineLayer = recyclePool.isEmpty
                ? _HexViewComponentLineLayer(drawingHelper: drawingHelper)
                : recyclePool.removeLast()
            
            lineLayer.representingLine = line
            lineLayer.loadData(from: dataProvider!)
            if forwards {
                lineLayers.append(lineLayer)
            } else {
                lineLayers.insert(lineLayer, at: 0)
            }
            layer?.addSublayer(lineLayer)
        }
        
        func layoutLine(_ line: _HexViewComponentLineLayer) {
            line.frame = .init(x: 0, y: lineHeight * CGFloat(line.representingLine),
                               width: viewportBounds.width, height: lineHeight)
        }
        
        // Then, append additional lines if needed.
        // Forwards:
        while true {
            let lastLine = lineLayers.last?.representingLine ?? (fromLine - 1)
            if lastLine >= toLine {
                break
            }
            addLineLayer(for: lastLine + 1)
        }
        // Backwards:
        while true {
            let firstLine = lineLayers.first?.representingLine ?? (toLine + 1)
            if firstLine <= fromLine {
                break
            }
            addLineLayer(for: firstLine - 1, forwards: false)
        }
        
        // All lines are added to the view, now layout them.
        lineLayers.forEach { layoutLine($0) }
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
