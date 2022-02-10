//
//  Created by Cyandev on 2022/2/10.
//  Copyright © 2022 Cyandev. All rights reserved.
//

import Cocoa

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
        }
    }
    
    var selectionFillColor: NSColor?
    var selectionStrokeColor: NSColor?
    
    var octetsPerLine = 16 {
        didSet {
            recalculateMetrics()
        }
    }
    
    var lineGap: CGFloat = 10 {
        didSet {
            recalculateMetrics()
        }
    }
    
    var gutterWidth: CGFloat = 80
    
    private(set) var charHeight: CGFloat = 0
    private(set) var lineHeight: CGFloat = 0
    private(set) var charDrawingOriginY: CGFloat = 0
    private(set) var charWidth: CGFloat = 0
    
    static func numberOfLineCharacters(for octets: Int) -> Int {
        // There will be a gap between every 8 octets.
        return octets * 3 - 1 + (octets / 8 - 1)
    }
    
    private func recalculateMetrics() {
        guard let font = self.font else {
            return
        }
        
        charHeight = font.ascender + font.descender
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
        // TODO: This function needs refactor to adapt the line width changes.
        
        let line = position.line
        let column = position.column
        
        let y = CGFloat(line) * lineHeight
        switch component {
        case .hex:
            if column < 8 {
                return .init(x: gutterWidth + charWidth * CGFloat(column) * 3, y: y)
            } else {
                let subColumn = CGFloat(column) - 8
                return .init(x: gutterWidth + charWidth * 25 + charWidth * subColumn * 3, y: y)
            }
        case .ascii:
            return .init(x: gutterWidth + charWidth * 50 + charWidth * CGFloat(column), y: y)
        }
    }
    
    func hitTest(at point: CGPoint) -> (ComponentType, Position)? {
        let pointX = point.x
        let line = Int(floor(point.y / lineHeight))
        
        // Anatomy of a line:
        // | GUTTER | 8 OCTETS | 8 OCTETS | 16 ASCII CHARS |
        //
        // We use the scanning fashion to determine the hit component.
        
        if pointX <= gutterWidth {
            return (.hex, .init(line: line, column: 0))
        }
        
        // First 8 octets:
        var startX = gutterWidth
        var endX = origin(of: .hex, at: .init(line: 0, column: 8)).x
        if pointX < endX {
            let column = min(max(Int(floor((pointX - startX) / (charWidth * 3))), 0), 7)
            return (.hex, .init(line: line, column: column))
        }
        
        // Second 8 octets:
        startX = endX
        endX = origin(of: .ascii, at: .init(line: 0, column: 0)).x
        if pointX < endX {
            let column = min(max(Int(floor((pointX - startX) / (charWidth * 3))), 0), 7)
            return (.hex, .init(line: line, column: 8 + column))
        }
        
        // Ascii characters area:
        startX = endX
        let column = min(max(Int(floor((pointX - startX) / charWidth)), 0), 15)
        return (.ascii, .init(line: line, column: column))
    }
    
}
