//
//  Created by ktiays on 2022/10/9.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import SwiftUI

@available(iOS 15.0, *)
struct PillContainerView: View {
    
    @ObservedObject private var stack: BannerManager._AnnouncementStack
    
    private let pillEndDisplay: (UUID) -> Void
    
    init(stack: BannerManager._AnnouncementStack, pillEndDisplay: @escaping (UUID) -> Void = { _ in }) {
        self.stack = stack
        self.pillEndDisplay = pillEndDisplay
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                HStack(spacing: 0) {
                    Color.clear
                }
                ForEach(stack.announcements) { item in
                    PillView(announcement: item.announcement) {
                        pillEndDisplay(item.id)
                    }
                    .transition(.asymmetric(insertion: .identity,
                                            removal: .scale(scale: 0.3).combined(with: .opacity)))
                }
            }
            .padding(.vertical, proxy.safeAreaInsets.top > 12 ? 0 : 12)
        }
    }
    
}

@available(iOS 15.0, *)
struct PillBannerContentModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 30)
            .padding(.vertical, 18)
            .frame(minWidth: 180)
            .background(Color.secondarySystemGroupedBackground.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
            .padding(.horizontal, 30)
    }
    
}

extension View {
    
    @available(iOS 15.0, *)
    func pillBannerContent() -> some View {
        modifier(PillBannerContentModifier())
    }
    
}

@available(iOS 15.0, *)
fileprivate struct PillView<A>: View where A: PresentableAnnouncement {
    
    private let announcement: A
    private let endDisplayAction: () -> Void
    
    @State private var frame: CGRect = .zero
    
    @State private var opacity: CGFloat = 0
    @State private var slideAnimated: Bool = false
    
    @State private var willDisappear: Bool = false
    
    init(announcement: A, endDisplayAction: @escaping () -> Void) {
        self.announcement = announcement
        self.endDisplayAction = endDisplayAction
    }
    
    var body: some View {
        announcement.content
            .offset(y: slideAnimated ? 0 : -frame.maxY)
            .opacity(opacity)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(in: .global)
                            opacity = 1
                            withAnimation(.spring()) {
                                slideAnimated.toggle()
                            }
                        }
                        .onChange(of: proxy.frame(in: .global)) { newValue in
                            if frame.width > newValue.width && !slideAnimated {
                                opacity = 0
                                willDisappear = true
                            }
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    if !willDisappear {
                        withAnimation(.spring()) {
                            slideAnimated.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(370)) {
                            endDisplayAction()
                        }
                    }
                }
            }
    }
    
}

#endif
