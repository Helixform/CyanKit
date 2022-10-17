//
//  Created by Cyandev on 2022/10/17.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import Foundation

class AnyError: NSError {
    
    let message: String?
    
    init(message: String, code: Int = -1, domain: String? = nil) {
        self.message = message
        super.init(domain: domain ?? "", code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
