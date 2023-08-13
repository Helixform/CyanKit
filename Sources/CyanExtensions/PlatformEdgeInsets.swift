//
//  Created by ktiays on 2023/8/13.
//  Copyright (c) 2023 ktiays. All rights reserved.
// 

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension PlatformEdgeInsets {
    var inverted: Self {
        .init(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
