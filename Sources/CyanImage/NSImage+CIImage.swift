//
//  Created by ktiays on 2022/10/14.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#if canImport(AppKit)

import AppKit

extension NSImage {
    
    public var ciImage: CIImage? {
        guard let data = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }
        return CIImage(bitmapImageRep: bitmap)
    }
    
}

extension NSImage {
    
    public convenience init(ciImage: CIImage) {
        let imageRep = NSCIImageRep(ciImage: ciImage)
        self.init(size: imageRep.size)
        self.addRepresentation(imageRep)
    }
    
}

#endif
