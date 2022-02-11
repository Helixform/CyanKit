//
//  Created by Cyandev on 2022/2/10.
//  Copyright © 2022 Cyandev. All rights reserved.
//

import Cocoa
import CoreGraphics

class HexViewDrawingHelper {
    
    enum ComponentType {
        case hex
        case ascii
        
        var stride: Int {
            switch self {
            case .hex:
                return 2
            case .ascii:
                return 1
            }
        }
    }
    
    struct Position: Comparable {
        let line: Int
        let column: Int
        
        static func < (lhs: HexViewDrawingHelper.Position, rhs: HexViewDrawingHelper.Position) -> Bool {
            if lhs.line < rhs.line {
                return true
            }
            if lhs.line == rhs.line {
                return lhs.column < rhs.column
            }
            return false
        }
    }
    
    var font: NSFont? {
        didSet {
            recalculateMetrics()
            prepareCaches()
        }
    }
    
    var selectionFillColor: NSColor?
    var selectionStrokeColor: NSColor?
    
    var octetsPerLine = 16
    var gutterWidth: CGFloat = 80
    var lineGap: CGFloat = 10 {
        didSet {
            recalculateMetrics()
        }
    }
    
    private(set) var charHeight: CGFloat = 0
    private(set) var lineHeight: CGFloat = 0
    private(set) var charDrawingOriginY: CGFloat = 0
    private(set) var charWidth: CGFloat = 0
    
    private var octetImageCache = [CGImage]()
    private var asciiImageCache = [CGImage]()
    
    private func recalculateMetrics() {
        guard let font = self.font else {
            return
        }
        
        charHeight = font.capHeight
        lineHeight = charHeight + lineGap
        charDrawingOriginY = font.ascender - font.capHeight
        
        // Assume that only monospaced fonts are set, each character will
        // has the same width.
        let sampleString = "0" as NSString
        let boundingRect = sampleString.boundingRect(
            with: .zero, options: [], attributes: [.font: font]
        )
        charWidth = boundingRect.width
    }
    
    private func prepareCaches() {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let scale = NSScreen.main?.backingScaleFactor ?? 2  // TODO: what if the main screen changed?
        let charVerticalAdjust = font!.descender + (lineHeight - charHeight) / 2
        
        func createCGImage(with string: String, color: NSColor? = nil) -> CGImage {
            let width = Int(ceil(charWidth * CGFloat(string.count)) * scale)
            let height = Int(ceil(lineHeight) * scale)
            let context = CGContext(data: nil, width: width, height: height,
                                    bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.scaleBy(x: scale, y: scale)
            
            // Become current context for Cocoa string drawing.
            NSGraphicsContext.current = .init(cgContext: context, flipped: false)
            
            (string as NSString).draw(at: .init(x: 0, y: charVerticalAdjust), withAttributes: [
                .font: self.font!,
                .foregroundColor: color ?? NSColor.textColor,
            ])
            
            let image = context.makeImage()!
            
            // Resign the current context.
            NSGraphicsContext.current = nil
            
            return image
        }
        
        let specialAsciiImage = createCGImage(with: ".", color: NSColor.textColor.withAlphaComponent(0.3))
        for i in 0...255 {
            octetImageCache.append(createCGImage(with: String(hexStringWith: i, uppercase: true, paddingTo: 2)))
            
            if i < 32 || i >= 127 {
                // These characters are invisible.
                asciiImageCache.append(specialAsciiImage)
            } else {
                asciiImageCache.append(createCGImage(with: String(Character(UnicodeScalar(UInt8(i))))))
            }
            
        }
    }
    
    func drawSelection(from startCharacterOrigin: CGPoint,
                       to endCharacterOrigin: CGPoint,
                       stride: CGFloat,
                       drawingBounds: CGRect,
                       in context: CGContext) {
        let selectionPath = NSBezierPath()
        selectionPath.move(to: startCharacterOrigin)
        if abs(startCharacterOrigin.y - endCharacterOrigin.y) < CGFloat.ulpOfOne {
            // One line.
            selectionPath.line(to: .init(x: endCharacterOrigin.x + charWidth * stride, y: endCharacterOrigin.y))
            selectionPath.line(to: .init(x: endCharacterOrigin.x + charWidth * stride,
                                         y: endCharacterOrigin.y + lineHeight))
            selectionPath.line(to: .init(x: startCharacterOrigin.x, y: startCharacterOrigin.y + lineHeight))
        } else {
            selectionPath.line(to: .init(x: drawingBounds.maxX, y: startCharacterOrigin.y))
            selectionPath.line(to: .init(x: drawingBounds.maxX, y: endCharacterOrigin.y))
            selectionPath.line(to: .init(x: endCharacterOrigin.x + charWidth * stride,
                                         y: endCharacterOrigin.y))
            selectionPath.line(to: .init(x: endCharacterOrigin.x + charWidth * stride,
                                         y: endCharacterOrigin.y + lineHeight))
            selectionPath.line(to: .init(x: drawingBounds.minX, y: endCharacterOrigin.y + lineHeight))
            selectionPath.line(to: .init(x: drawingBounds.minX, y: startCharacterOrigin.y + lineHeight))
            selectionPath.line(to: .init(x: startCharacterOrigin.x, y: startCharacterOrigin.y + lineHeight))
        }
        selectionPath.close()
        
        if let selectionStrokeColor = self.selectionStrokeColor {
            context.setStrokeColor(selectionStrokeColor.cgColor)
        }
        if let selectionFillColor = selectionFillColor {
            context.setFillColor(selectionFillColor.cgColor)
        }
        
        selectionPath.fill()
        selectionPath.stroke()
    }
    
    func dataIndex(at position: Position) -> Int {
        return position.line * octetsPerLine + position.column
    }
    
    func origin(of component: ComponentType, at position: Position) -> CGPoint {
        let line = position.line
        let column = position.column
        
        let y = CGFloat(line) * lineHeight
        switch component {
        case .hex:
            return .init(x: gutterWidth + charWidth * CGFloat(column) * 3, y: y)
        case .ascii:
            let startX = gutterWidth + charWidth * (CGFloat(octetsPerLine) * 3 + 2)
            return .init(x: startX + charWidth * CGFloat(column), y: y)
        }
    }
    
    func hitTest(at point: CGPoint) -> (ComponentType, Position)? {
        let pointX = point.x
        let line = Int(floor(point.y / lineHeight))
        
        // Anatomy of a line:
        // | GUTTER | OCTETS | ASCII CHARS |
        //
        // We use the scanning fashion to determine the hit component.
        
        if pointX <= gutterWidth {
            return (.hex, .init(line: line, column: 0))
        }
        
        // Octets area:
        var startX = gutterWidth
        var endX = origin(of: .ascii, at: .init(line: 0, column: 0)).x
        if pointX < endX {
            let column = min(max(Int(floor((pointX - startX) / (charWidth * 3))), 0), octetsPerLine - 1)
            return (.hex, .init(line: line, column: column))
        }
        
        // Ascii characters area:
        startX = endX
        let column = min(max(Int(floor((pointX - startX) / charWidth)), 0), octetsPerLine - 1)
        return (.ascii, .init(line: line, column: column))
    }
    
    @inline(__always) func octetImage(of byte: UInt8) -> CGImage {
        return octetImageCache[Int(byte)]
    }
    
    @inline(__always) func asciiImage(of byte: UInt8) -> CGImage {
        return asciiImageCache[Int(byte)]
    }
    
}

class _HexViewComponentLineLayer: CALayer {
    
    let drawingHelper: HexViewDrawingHelper
    var representingLine: Int = -1
    
    private var hexComponents = [_HexViewComponentLayer]()
    private var asciiComponents = [_HexViewComponentLayer]()
    
    init(drawingHelper: HexViewDrawingHelper) {
        self.drawingHelper = drawingHelper
        super.init()
        commomInit()
    }

    required init?(coder: NSCoder) {
        fatalError("Should not call this initializer")
    }
    
    private func commomInit() {
        let charWidth = drawingHelper.charWidth
        let lineHeight = drawingHelper.lineHeight
        let font = drawingHelper.font!
        let fontSize = font.pointSize
        let screenScale = NSScreen.main?.backingScaleFactor ?? 2
        
        // Populate components.
        var currentComponentWidth = charWidth * 2
        for i in 0..<drawingHelper.octetsPerLine {
            let component = _HexViewComponentLayer()
            component.frame = .init(
                origin: .init(x: drawingHelper.origin(of: .hex, at: .init(line: representingLine, column: i)).x, y: 0),
                size: .init(width: currentComponentWidth, height: lineHeight)
            )
            
            hexComponents.append(component)
            addSublayer(component)
        }
        
        currentComponentWidth = charWidth * 1
        for i in 0..<drawingHelper.octetsPerLine {
            let component = _HexViewComponentLayer()
            component.frame = .init(
                origin: .init(x: drawingHelper.origin(of: .ascii, at: .init(line: representingLine, column: i)).x, y: 0),
                size: .init(width: currentComponentWidth, height: lineHeight)
            )
            
            asciiComponents.append(component)
            addSublayer(component)
        }
    }
    
    func loadData(from dataProvider: HexViewDataProvider) {
        let length = dataProvider.length
        let start = drawingHelper.dataIndex(at: .init(line: representingLine, column: 0))
        let end = min(length - 1, drawingHelper.dataIndex(at: .init(line: representingLine,
                                                                    column: drawingHelper.octetsPerLine - 1)))
        
        for i in 0..<drawingHelper.octetsPerLine {
            let hexComponent = hexComponents[i]
            let asciiComponent = asciiComponents[i]
            
            let dataIndex = start + i
            if dataIndex > end {
                hexComponent.contents = nil
                asciiComponent.contents = nil
            } else {
                let byte = dataProvider.byte(at: dataIndex)
                hexComponent.contents = drawingHelper.octetImage(of: byte)
                asciiComponent.contents = drawingHelper.asciiImage(of: byte)
            }
        }
    }
    
}

fileprivate class _HexViewComponentLayer: CALayer {
    
    override func action(forKey event: String) -> CAAction? {
        return NSNull()
    }
    
}
