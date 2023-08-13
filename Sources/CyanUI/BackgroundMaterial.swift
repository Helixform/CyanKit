//
//  Created by ktiays on 2022/5/31.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if os(macOS)

import SwiftUI

@available(macOS 11.0, *)
public struct BackgroundMaterial: View {
    
    let blendColor: Color?
    
    public init(blendColor: Color? = nil) {
        self.blendColor = blendColor
    }
    
    public var body: some View {
        VisualEffectView(
            state: .followsWindowActiveState,
            material: .hudWindow,
            blendingMode: .behindWindow
        )
        .overlay(
            blendColor ?? Color.windowBackground
                .opacity(0.4)
        )
    }
}

#endif
