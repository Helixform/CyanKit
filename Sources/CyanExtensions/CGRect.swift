//
//  Created by ktiays on 2023/8/13.
//  Copyright (c) 2023 ktiays. All rights reserved.
//

import CoreGraphics
import Foundation

extension CGRect {
    
    #if os(macOS)
    public func inset(by insets: NSEdgeInsets) -> Self {
        .init(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: width - insets.left - insets.right,
            height: height - insets.top - insets.bottom
        )
    }
    #endif
    
    public func inflate(by insets: PlatformEdgeInsets) -> Self {
        inset(by: insets.inverted)
    }
}
