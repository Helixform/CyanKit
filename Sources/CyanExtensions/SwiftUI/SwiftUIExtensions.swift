//
//  Created by Cyandev on 2022/1/14.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import SwiftUI

// MARK: View

public extension View {
    
    func hideListRowSeparator() -> some View {
        #if os(iOS)
        Group {
            if #available(iOS 15.0, *) {
                listRowSeparator(.hidden)
            } else {
                self
            }
        }
        #else
        self
        #endif
    }
    
}

// MARK: - EdgeInsets

public extension EdgeInsets {
    
    /// An edge insets struct whose top, left, bottom, and right fields are all set to 0.
    static let zero: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
}
