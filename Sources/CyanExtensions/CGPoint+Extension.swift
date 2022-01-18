//
//  Created by ktiays on 2022/1/18.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation
import CoreGraphics

public extension CGPoint {
    
    func nearBy(_ point: CGPoint, tolerance: CGFloat = 2) -> Bool {
        abs(x - point.x) <= tolerance && abs(y - point.y) <= tolerance
    }
    
}
