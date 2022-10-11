//
//  Created by ktiays on 2022/10/11.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import CoreImage
import CyanExtensions

func dominantColor(for image: CIImage) -> [PlatformColor] {
    guard let kMeansFilter = CIFilter(name: "CIKMeans") else {
        return []
    }
    let clusterCount = 3
    
    kMeansFilter.setValue(image, forKey: kCIInputImageKey)
    kMeansFilter.setValue(CIVector(cgRect: image.extent), forKey: kCIInputExtentKey)
    kMeansFilter.setValue(clusterCount, forKey: "inputCount")
    kMeansFilter.setValue(NSNumber(value: true), forKey: "inputPerceptual")
    
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
                   colorSpace: image.colorSpace!)
    print(bitmap)
    
    var dominantColors = [PlatformColor]()
    
    for i in 0..<clusterCount {
        let color = PlatformColor(red: CGFloat(bitmap[i * 4 + 0]) / 255.0, green: CGFloat(bitmap[i * 4 + 1]) / 255.0, blue: CGFloat(bitmap[i * 4 + 2]) / 255.0, alpha: CGFloat(bitmap[i * 4 + 3]) / 255.0)
        dominantColors.append(color)
    }
    
    return dominantColors
}

