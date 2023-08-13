//
//  Created by ktiays on 2023/8/13.
//  Copyright (c) 2023 ktiays. All rights reserved.
// 

#if os(macOS)
import Foundation

public typealias PlatformEdgeInsets = NSEdgeInsets

public extension NSEdgeInsets {
    static let zero: NSEdgeInsets = NSEdgeInsetsZero
}
#endif
