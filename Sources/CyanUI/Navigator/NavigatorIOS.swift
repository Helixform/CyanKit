//
//  Created by ktiays on 2022/3/26.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import SwiftUI

public struct Navigator<Content>: UIViewControllerRepresentable where Content: View {
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        .init(rootViewController: UIHostingController(rootView: content))
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
    
}

public struct NavigatorReader<Content>: View where Content: View {
    
    private let contentBuilder: (NavigatorProxy) -> Content
    
    @State private var uiView: UIView = .init()
    
    public init(@ViewBuilder content: @escaping (NavigatorProxy) -> Content) {
        self.contentBuilder = content
    }
    
    public var body: some View {
        contentBuilder(.init(uiView: uiView))
            .background(
                _HostingView(uiView: uiView)
                    .frame(width: 1, height: 1)
            )
    }
    
    private struct _HostingView: UIViewRepresentable {
        
        private let uiView: UIView
        
        init(uiView: UIView) {
            self.uiView = uiView
        }
        
        func makeUIView(context: Context) -> UIView { uiView }
        
        func updateUIView(_ uiView: UIView, context: Context) { }
    }
    
}

public struct NavigatorProxy {
    
    private let uiView: UIView
    
    init(uiView: UIView) {
        self.uiView = uiView
    }
    
    public func push<V>(animated: Bool = true, @ViewBuilder view: () -> V) where V: View {
        uiView.cyan.viewController?.navigationController?.pushViewController(UIHostingController(rootView: view()), animated: animated)
    }
    
}

#endif
