//
//  Created by ktiays on 2022/3/26.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import SwiftUI

struct NavigatorIOS<Content>: UIViewControllerRepresentable where Content: View {
    
    private let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        .init(rootViewController: _ChildViewHostingController(rootView: content))
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
    
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
                _NavigationControllerLocator(uiView: uiView)
                    .frame(width: 0, height: 0)
            )
    }
    
    private struct _NavigationControllerLocator: UIViewRepresentable {
        
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
        uiView.cyan
            .viewController?
            .navigationController?
            .pushViewController(_ChildViewHostingController(rootView: view()), animated: animated)
    }
    
}

fileprivate struct _NavigationItemReceiver<Content>: View where Content: View {
    
    let controller: _ChildViewHostingController<Content>
    let content: Content
    
    var body: some View {
        content
            .onPreferenceChange(NavigatorTitlePreferenceKey.self) { [unowned controller] title in
                controller.title = title
            }
    }
    
}

fileprivate class _ChildViewHostingController<Content>: UIHostingController<_NavigationItemReceiver<Content>?> where Content: View {
    
    init(rootView: Content) {
        super.init(rootView: nil)
        
        // Hack: changing title during the push transition will cause the title
        // view to flash to the finish state directly. We need to extract the
        // title preference before pushing is initiated.
        func findPreference<K>(of keyType: K.Type, from view: Any) -> K.Value? where K: PreferenceKey {
            guard String(describing: type(of: view)).hasPrefix("ModifiedContent") else {
                return nil
            }
            
            let mirror = Mirror(reflecting: view)
            for child in mirror.children {
                if child.label == "modifier" {
                    // Find our modifier.
                    let childValue = child.value
                    let childTypeName = String(describing: type(of: childValue))
                    if childTypeName.hasPrefix("_PreferenceWritingModifier") {
                        let childMirror = Mirror(reflecting: childValue)
                        let modifierTypeName = childTypeName.split(separator: "<")[1].dropLast(1)
                        if modifierTypeName == String(describing: keyType) {
                            return (childMirror.children.first!.value as! K.Value)
                        }
                    }
                } else if child.label == "content" {
                    // Recursively find in child views.
                    if let value = findPreference(of: keyType, from: child.value) {
                        return value
                    }
                }
            }
            
            return nil
        }
        self.title = findPreference(of: NavigatorTitlePreferenceKey.self, from: rootView.body)
        
        self.rootView = _NavigationItemReceiver(controller: self, content: rootView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#endif
