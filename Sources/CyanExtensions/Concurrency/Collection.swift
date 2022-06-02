//
//  Created by ktiays on 2022/6/2.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

extension Collection {
    
    /// Asynchronously creates an array containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// - Parameter transform: An asynchronous mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type.
    ///
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    @inlinable
    public func map<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        let n = self.count
        if n == 0 {
            return []
        }
        
        var result = ContiguousArray<T>()
        result.reserveCapacity(n)
        
        var i = self.startIndex
        
        for _ in 0..<n {
            result.append(try await transform(self[i]))
            formIndex(after: &i)
        }
        
        return Array(result)
    }
    
}
