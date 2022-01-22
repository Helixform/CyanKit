//
//  Created by Cyandev on 2022/1/22.
//  Copyright (c) 2021 Cyandev. All rights reserved.
//

import SwiftUI
import CyanUtils

public struct AnyViewModifier: ViewModifier {
    
    private let bodyBuilder: (Content) -> AnyView
    
    public init<V>(@ViewBuilder _ viewModifier: @escaping (Content) -> V) where V: View {
        bodyBuilder = { content in
            AnyView(content |> viewModifier)
        }
    }
    
    public init<V>(_ viewModifier: V) where V: ViewModifier {
        bodyBuilder = { content in
            AnyView(content.modifier(viewModifier))
        }
    }
    
    public init() {
        bodyBuilder = { AnyView($0) }
    }
    
    public func body(content: Content) -> some View {
        content |> bodyBuilder
    }
    
    public func typeErasedConcat<T>(_ modifier: T) -> AnyViewModifier where T: ViewModifier {
        return .init(concat(modifier))
    }
    
}
