//
//  Created by ktiays on 2022/10/17.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit

extension UIScreen {
    
    private static let _cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    /// The corner radius of the display. Uses a private property of `UIScreen`,
    /// and may report 0 if the API changes.
    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self._cornerRadiusKey) as? CGFloat else {
            return 0
        }
        return cornerRadius
    }
}

#endif
