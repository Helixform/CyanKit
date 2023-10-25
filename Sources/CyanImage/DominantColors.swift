//
//  Created by ktiays on 2022/10/11.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import CoreImage
import CyanExtensions

extension CIImage {
    
    public func dominantColor(clusterCount: Int = 5) -> [PlatformColor] {
        guard let kMeansFilter = CIFilter(name: "CIKMeans") else {
            return []
        }
        
        kMeansFilter.setValue(self, forKey: kCIInputImageKey)
        kMeansFilter.setValue(CIVector(cgRect: self.extent), forKey: kCIInputExtentKey)
        kMeansFilter.setValue(clusterCount, forKey: "inputCount")
        kMeansFilter.setValue(20, forKey: "inputPasses")
        
        guard var outputImage = kMeansFilter.outputImage else {
            return []
        }
        
        outputImage = outputImage.settingAlphaOne(in: outputImage.extent)
        
        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4 * clusterCount)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4 * clusterCount,
                       bounds: outputImage.extent,
                       format: CIFormat.RGBA8,
                       colorSpace: self.colorSpace!)
        
        var dominantColors = [PlatformColor]()
        
        for i in 0..<clusterCount {
            let color = PlatformColor(red: CGFloat(bitmap[i * 4 + 0]) / 255.0, green: CGFloat(bitmap[i * 4 + 1]) / 255.0, blue: CGFloat(bitmap[i * 4 + 2]) / 255.0, alpha: CGFloat(bitmap[i * 4 + 3]) / 255.0)
            dominantColors.append(color)
        }
        
        return dominantColors
    }
    
}

#if canImport(UIKit)

import UIKit

extension UIImage {
    
    @inlinable
    public func dominantColors(clusterCount: Int = 5) -> [UIColor] {
        CIImage(image: self)?.dominantColor(clusterCount: clusterCount) ?? []
    }
    
}

#elseif canImport(AppKit)

import AppKit

extension NSImage {
    
    public func dominantColors(clusterCount: Int = 5) -> [NSColor] {
        ciImage?.dominantColor(clusterCount: clusterCount) ?? []
    }
    
}

#endif
