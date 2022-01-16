//
//  Created by ktiays on 2022/1/15.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import SwiftUI

@available(macOS 11.0, *)
public struct VisualEffectView: NSViewRepresentable {
    
    public typealias BlendingMode = NSVisualEffectView.BlendingMode
    public typealias Material = NSVisualEffectView.Material
    public typealias State = NSVisualEffectView.State
    
    public let state: State
    public let blendingMode: BlendingMode
    public let material: Material
    
    public init(state: State = .active, material: Material = .contentBackground, blendingMode: BlendingMode = .behindWindow) {
        self.state = state
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView { .init() }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.state = state
        nsView.blendingMode = blendingMode
        nsView.material = material
    }
    
}
