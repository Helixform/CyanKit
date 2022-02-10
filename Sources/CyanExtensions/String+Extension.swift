//
//  Created by Cyandev on 2022/2/10.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import Foundation

public extension String {
    
    init<I: BinaryInteger>(hexStringWith value: I, uppercase: Bool, paddingTo digits: Int? = nil) {
        var hexString = String(value, radix: 16, uppercase: true)
        if let padding = digits, hexString.count < padding {
            hexString = String(repeating: "0", count: padding - hexString.count) + hexString
        }
        self.init(hexString)
    }
    
}
