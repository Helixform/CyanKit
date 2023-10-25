//
//  Created by ktiays on 2022/10/17.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#if canImport(UIKit)

import UIKit

extension UIImage {
    
    public convenience init?(with color: UIColor, size: CGSize = .init(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
}

#elseif canImport(AppKit)

import AppKit

extension NSImage {
    
    public convenience init(color: NSColor, size: NSSize = .init(width: 1, height: 1)) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }
    
}

#endif
