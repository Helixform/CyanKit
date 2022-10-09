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
    public func mapAsync<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        let n = self.count
        if n == 0 {
            return []
        }
        
        return try await withThrowingTaskGroup(of: (Int, T).self, returning: [T].self) { group in
            for (index, elem) in self.enumerated() {
                group.addTask {
                    return (index, try await transform(elem))
                }
            }
            
            var sparseArray = [Int : T](minimumCapacity: n)
            
            for try await (index, resultElem) in group {
                sparseArray[index] = resultElem
            }
            
            return sparseArray
                .sorted { lhs, rhs in lhs.key < rhs.key }
                .map { $0.value }
        }
    }
    
}
