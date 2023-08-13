//
//  Created by ktiays on 2023/8/13.
//  Copyright (c) 2023 ktiays. All rights reserved.
// 

#if os(iOS)
import SwiftUI
import UIKit
import CyanUtils
import CyanExtensions
import ObjectiveC

@available(iOS 15.0, *)
public struct EditMenuModifier: ViewModifier {
    /// A rectangle with edges moved outwards by the given insets.
    private let insets: UIEdgeInsets
    private let items: () -> [EditMenuAction]
    
    public init(insets: UIEdgeInsets = .zero, @ArrayBuilder<EditMenuAction> items: @escaping () -> [EditMenuAction]) {
        self.insets = insets
        self.items = items
    }
    
    public func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { 
                        // If empty `onTapGesture` block is not added, the outer `List` will not be able to scroll.
                        // This may be a bug in SwiftUI.
                    }
                    .onLongPressGesture {
                        let items = items()
                        if items.isEmpty { return }
                        
                        let menuController = UIMenuController.shared
                        let dummyView = editMenuDummyView()
                        dummyView.removeFromSuperview()
                        guard let keyWindow = UIApplication.shared.cyan.keyWindow else {
                            return
                        }
                        dummyView.frame = proxy.frame(in: .global).inflate(by: insets)
                        dummyView.actionHandler = { [unowned dummyView] index in
                            defer { dummyView.resignFirstResponder() }
                            if index >= items.count { return }
                            items[index].action()
                        }
                        keyWindow.addSubview(dummyView)
                        dummyView.becomeFirstResponder()
                        
                        menuController.menuItems = items.enumerated().map { (index, action) in
                            return .init(
                                title: action.title ?? "",
                                action: _DummyView.selector(for: index)
                            )
                        }
                        menuController.showMenu(from: dummyView, rect: dummyView.bounds)
                    }
            }
        }
    }
    
    private func editMenuDummyView() -> _DummyView {
        if let view = UIMenuController.shared.dummyView {
            return view
        }
        let view = _DummyView()
        UIMenuController.shared.dummyView = view
        return view
    }
    
    fileprivate class _DummyView: UIView {
        static var key: Void? = nil
        static let selectorPrefix = "__dynamicallyInvokeAction🪵"
        
        var actionHandler: ((Int) -> Void)?
        
        static func selector(for index: Int) -> Selector {
            Selector("\(selectorPrefix)\(index)")
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.isUserInteractionEnabled = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        class func willRespond(to selector: Selector) -> Bool {
            NSStringFromSelector(selector).hasPrefix(selectorPrefix)
        }
        
        override class func resolveInstanceMethod(_ selector: Selector!) -> Bool {
            func resolveSelector(_ selector: Selector) -> Int? {
                let name = NSStringFromSelector(selector)
                guard name.hasPrefix(_DummyView.selectorPrefix),
                      let index = Int(name.dropFirst(_DummyView.selectorPrefix.count))
                else {
                    return nil
                }
                return index
            }
            
            func dynamicallyInvokeAction🪵(_self: Any, _cmd: Selector, sender: Any) {
                guard let self = _self as? _DummyView else {
                    assertionFailure("Invalid receiver for selector `\(_cmd)`")
                    return
                }
                guard let index = resolveSelector(_cmd) else {
                    assertionFailure("Invalid selector `\(_cmd)`")
                    return
                }
                self.actionHandler?(index)
            }
            
            guard resolveSelector(selector) != nil else {
                return super.resolveInstanceMethod(selector)
            }
            
            return class_addMethod(
                self, 
                selector,
                unsafeBitCast(
                    dynamicallyInvokeAction🪵 as (@convention(c) (Any, Selector, Any) -> Void),
                    to: IMP.self
                ),
                "v@:@"
            )
        }
    }
}

@available(iOS 15.0, *)
private extension UIMenuController {
    var dummyView: EditMenuModifier._DummyView? {
        set {
            objc_setAssociatedObject(self, &EditMenuModifier._DummyView.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &EditMenuModifier._DummyView.key) as? EditMenuModifier._DummyView
        }
    }
}

@available(iOS 15.0, *)
public struct EditMenuAction {
    public let title: String?
    public let action: () -> Void
    
    public init(_ title: String?, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

@available(iOS 15.0, *)
public extension View {
    func editMenu(insets: UIEdgeInsets = .zero, @ArrayBuilder<EditMenuAction> _ actions: @escaping () -> [EditMenuAction]) -> some View {
        modifier(EditMenuModifier(insets: insets, items: actions))
    }
}
#endif
