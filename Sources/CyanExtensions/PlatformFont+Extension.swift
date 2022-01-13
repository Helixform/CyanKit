//
//  Created by ktiays on 2022/1/14.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#if os(iOS)
import UIKit
public typealias PlatformFont = UIFont
#else
import AppKit
public typealias PlatformFont = NSFont
#endif
