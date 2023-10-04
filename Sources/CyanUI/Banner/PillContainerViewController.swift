//
//  Created by ktiays on 2022/10/9.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if os(iOS) || targetEnvironment(macCatalyst)

import UIKit
import SwiftUI

@available(iOS 15.0, *)
class PillContainerHostingView: UIView {
    
    private let hostingView: _UIHostingView<PillContainerView>
    
    init(rootView: PillContainerView) {
        hostingView = _UIHostingView(rootView: rootView)
        hostingView.backgroundColor = .clear
        
        super.init(frame: .zero)

        addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return (view === self || view === hostingView) ? nil : view
    }
    
}

#endif
