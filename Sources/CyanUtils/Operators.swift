//
//  Created by ktiays on 2022/1/8.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation
import CoreGraphics

infix operator |> : MultiplicationPrecedence
public func |><T, U>(_ lhs: T, _ rhs: (T) -> U) -> U {
    rhs(lhs)
}

// MARK: - Int & CGFloat

public func + (_ lhs: Int, _ rhs: CGFloat) -> CGFloat {
    CGFloat(lhs) + rhs
}

public func + (_ lhs: CGFloat, _ rhs: Int) -> CGFloat {
    lhs + CGFloat(rhs)
}

public func - (_ lhs: Int, _ rhs: CGFloat) -> CGFloat {
    CGFloat(lhs) - rhs
}

public func - (_ lhs: CGFloat, _ rhs: Int) -> CGFloat {
    lhs - CGFloat(rhs)
}

public func * (_ lhs: Int, _ rhs: CGFloat) -> CGFloat {
    CGFloat(lhs) * rhs
}

public func * (_ lhs: CGFloat, _ rhs: Int) -> CGFloat {
    lhs * CGFloat(rhs)
}

// MARK: - CGPoint

public func + (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func += (_ lhs: inout CGPoint, _ rhs: CGPoint) {
    lhs = .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func + (_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
    .init(width: lhs.width + rhs, height: lhs.height + rhs)
}

public func - (_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
    .init(width: lhs.width - rhs, height: lhs.height - rhs)
}
