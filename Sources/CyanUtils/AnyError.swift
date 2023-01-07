//
//  Created by Cyandev on 2022/10/17.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import Foundation

public class AnyError: NSError {
    
    public let message: String?
    
    public init(message: String, code: Int = -1, domain: String? = nil) {
        self.message = message
        super.init(domain: domain ?? "", code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
