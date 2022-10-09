//
//  Created by ktiays on 2022/10/9.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

@available(iOS 15.0, *)
public class BannerManager {
    
    class _AnnouncementStack: ObservableObject {
        
        struct IdentifiedAnnouncement: Identifiable {
            var id: UUID
            var announcement: AnyPresentableAnnouncement
            
            init<A>(announcement: A) where A: PresentableAnnouncement {
                self.id = UUID()
                self.announcement = AnyPresentableAnnouncement(announcement)
            }
        }
        
        @Published var announcements: [IdentifiedAnnouncement] = []
        
        func push<A>(announcement: A) where A: PresentableAnnouncement {
            if !announcements.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80)) {
                    let _ = withAnimation(.spring()) {
                        self.announcements.removeFirst()
                    }
                }
            }
            announcements.append(.init(announcement: announcement))
        }
        
        fileprivate func remove(for id: UUID) {
            guard let index = announcements.firstIndex(where: { announcement in
                announcement.id == id
            }) else { return }
            announcements.remove(at: index)
        }
        
    }
    
    public static let shared = BannerManager()
    
    let announcementStack = _AnnouncementStack()
    
    public func post<A>(announcement: A) where A: PresentableAnnouncement {
        announcementStack.push(announcement: announcement)
    }
    
    public func makeBannerContainerView() -> UIView {
        PillContainerHostingView(rootView: PillContainerView(stack: announcementStack, pillEndDisplay: { id in
            self.announcementStack.remove(for: id)
        }))
    }
    
}

@available(iOS 15.0, *)
public protocol PresentableAnnouncement {
    
    associatedtype Content: View
    
    @ViewBuilder var content: Self.Content { get }
    
}

@available(iOS 15.0, *)
public struct AnyPresentableAnnouncement: PresentableAnnouncement {
    
    public typealias Content = AnyView
    
    private let announcementContent: Self.Content
    
    public init<A>(_ announcement: A) where A: PresentableAnnouncement {
        self.announcementContent = AnyView(announcement.content)
    }
    
    public var content: AnyView { announcementContent }
    
}

@available(iOS 15.0, *)
extension String: PresentableAnnouncement {
    
    public var content: some View {
        Text(self)
            .pillBannerContent()
    }
    
}

#endif
