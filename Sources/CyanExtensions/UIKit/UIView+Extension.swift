//
//  Created by ktiays on 2022/10/17.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#if canImport(UIKit)

import UIKit

extension UIView {
    
    public var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { layer.cornerRadius }
    }
    
    public var cornerCurve: CALayerCornerCurve {
        set { layer.cornerCurve = newValue }
        get { layer.cornerCurve }
    }
    
}

#endif
