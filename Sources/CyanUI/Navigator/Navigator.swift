//
//  Created by Cyandev on 2022/3/26.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import SwiftUI

public struct Navigator<Content>: View where Content: View {
    
    let contentBuilder: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.contentBuilder = content
    }
    
    public var body: some View {
        NavigatorIOS(content: contentBuilder())
            .ignoresSafeArea()
    }
    
}

struct NavigatorTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String = ""
    
    typealias Value = String
    
    static func reduce(value: inout String, nextValue: () -> String) {
        
    }
    
}

extension View {
    
    public func navigatorTitle(_ title: String) -> some View {
        return self.preference(key: NavigatorTitlePreferenceKey.self, value: title)
    }
    
}
