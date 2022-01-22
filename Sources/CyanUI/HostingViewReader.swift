//
//  Created by ktiays on 2022/1/22.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import SwiftUI
#if os(macOS)
import AppKit
typealias ViewRepresentable = NSViewRepresentable
#else
import UIKit
typealias ViewRepresentable = UIViewRepresentable
#endif

struct HostingViewReader<Content>: ViewRepresentable where Content: View {
    
    #if os(macOS)
    
    typealias PlatformView = NSView
    typealias PlatformHostingView = NSHostingView
    
    func makeNSView(context: Context) -> _HostingView {
        .init(content: self.contentBuilder)
    }
    
    func updateNSView(_ nsView: _HostingView, context: Context) { }
    
    #else
    
    typealias PlatformView = UIView
    typealias PlatformHostingView = _UIHostingView
    
    func makeUIView(context: Context) -> _HostingView {
        .init(content: self.contentBuilder)
    }
    
    func updateUIView(_ uiView: _HostingView, context: Context) { }
    
    #endif
    
    private let contentBuilder: (PlatformView) -> Content

    
    init(@ViewBuilder content: @escaping (PlatformView) -> Content) {
        self.contentBuilder = content
    }
    
    final class _HostingView: PlatformView {
        
        private var contentView: Content!
        
        fileprivate init(@ViewBuilder content: (PlatformView) -> Content) {
            super.init(frame: .zero)
            self.contentView = content(self)

            let hostingContentView = PlatformHostingView(rootView: self.contentView)
            addSubview(hostingContentView)
            hostingContentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
