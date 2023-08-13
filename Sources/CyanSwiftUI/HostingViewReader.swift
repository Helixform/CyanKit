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

public struct HostingViewReader<Content>: ViewRepresentable where Content: View {
    
    #if os(macOS)
    public typealias PlatformView = NSView
    
    public func makeNSView(context: Context) -> _HostingViewWrapper {
        .init(frame: .zero)
    }
    
    public func updateNSView(_ nsView: _HostingViewWrapper, context: Context) {
        nsView.hostingView.rootView = self.contentBuilder(nsView)
    }
    #else
    public typealias PlatformView = UIView
    
    public func makeUIView(context: Context) -> _HostingViewWrapper {
        .init(frame: .zero)
    }
    
    public func updateUIView(_ uiView: _HostingViewWrapper, context: Context) {
        uiView.hostingViewController.rootView = self.contentBuilder(uiView)
    }
    #endif
    
    private let contentBuilder: (PlatformView) -> Content
    
    public init(@ViewBuilder content: @escaping (PlatformView) -> Content) {
        self.contentBuilder = content
    }
    
    public final class _HostingViewWrapper: PlatformView {
        
        #if os(macOS)
        fileprivate let hostingView: NSHostingView<Content?>
        #else
        fileprivate let hostingViewController: UIHostingController<Content?>
        #endif
        
        override init(frame: CGRect) {
            #if os(macOS)
            hostingView = .init(rootView: nil)
            #else
            hostingViewController = .init(rootView: nil)
            let hostingView: UIView = hostingViewController.view
            #endif
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            
            super.init(frame: frame)
            hostingView.backgroundColor = .clear
            
            addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: self.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
