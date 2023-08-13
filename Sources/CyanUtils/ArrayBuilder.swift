//
//  Created by ktiays on 2023/8/13.
//  Copyright (c) 2023 ktiays. All rights reserved.
//

import Foundation

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] {
        components
    }
    
    public static func buildBlock(_ componentGroups: [Element]...) -> [Element] {
        componentGroups.flatMap { $0 }
    }
    
    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }
    
    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }
    
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }
    
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }
    
    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }
    
    public static func buildFinalResult(_ component: [Element]) -> [Element] {
        component
    }
}
