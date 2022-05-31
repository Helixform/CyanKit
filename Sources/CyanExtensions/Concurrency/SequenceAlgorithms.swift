//
//  Created by ktiays on 2022/5/31.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

extension Sequence {
    
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
    public func map<T>(_ transform: (Self.Element) async throws -> T) async rethrows -> [T] {
        let initialCapacity = underestimatedCount
        var result = ContiguousArray<T>()
        result.reserveCapacity(initialCapacity)
        
        var iterator = self.makeIterator()
        
        // Add elements up to the initial capacity without checking for regrowth.
        for _ in 0..<initialCapacity {
            result.append(try await transform(iterator.next()!))
        }
        // Add remaining elements, if any.
        while let element = iterator.next() {
            result.append(try await transform(element))
        }
        return Array(result)
    }
    
}

extension Sequence {
    
    /// Asynchronously creates an array containing, in order, the elements of the sequence
    /// that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: An asynchronous closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be included in the returned array.
    ///
    /// - Returns: An array of the elements that `isIncluded` allowed.
    @inlinable
    public func filter(_ isIncluded: (Element) async throws -> Bool) async rethrows -> [Element] {
        var result = ContiguousArray<Element>()
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try await isIncluded(element) {
                result.append(element)
            }
        }
        return Array(result)
    }
    
}

extension Sequence {
    
    /// Calls the given asynchronous closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: An asynchronous closure that takes an element of the sequence as a
    ///   parameter.
    @inlinable
    public func forEach(_ body: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await body(element)
        }
    }
    
}

extension Sequence {
    
    /// Asynchronously creates an array containing the non-`nil` results of calling the given
    /// transformation with each element of this sequence.
    ///
    /// Use this method to receive an array of non-optional values when your
    /// transformation produces an optional value.
    ///
    /// - Parameter transform: An asynchronous closure that accepts an element of this
    ///   sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-`nil` results of calling `transform`
    ///   with each element of the sequence.
    @inlinable
    public func compactMap<ElementOfResult>(_ transform: (Element) async throws -> ElementOfResult?) async rethrows -> [ElementOfResult] {
        var result: [ElementOfResult] = []
        for element in self {
            if let newElement = try await transform(element) {
                result.append(newElement)
            }
        }
        return result
    }
    
}

extension Sequence {
    
    /// Asynchronously returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(_:_:)` method to produce a single value from the elements
    /// of an entire sequence.
    ///
    /// The asynchronous `nextPartialResult` closure is called sequentially with an
    /// accumulating value initialized to `initialResult` and each element of
    /// the sequence.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///     `initialResult` is passed to `nextPartialResult` the first time the
    ///     closure is executed.
    ///   - nextPartialResult: An asynchronous closure that combines an accumulating value and
    ///     an element of the sequence into a new accumulating value, to be used
    ///     in the next call of the `nextPartialResult` closure or returned to
    ///     the caller.
    ///
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    @inlinable
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (_ partialResult: Result, Element) async throws -> Result) async rethrows -> Result {
        var accumulator = initialResult
        for element in self {
            accumulator = try await nextPartialResult(accumulator, element)
        }
        return accumulator
    }
    
    /// Asynchronously returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(into:_:)` method to produce a single value from the
    /// elements of an entire sequence.
    ///
    /// This method is preferred over `reduce(_:_:)` for efficiency when the
    /// result is a copy-on-write type, for example an Array or a Dictionary.
    ///
    /// The asynchronous `updateAccumulatingResult` closure is called sequentially with a
    /// mutable accumulating value initialized to `initialResult` and each element
    /// of the sequence.
    ///
    /// If the sequence has no elements, `updateAccumulatingResult` is never
    /// executed and `initialResult` is the result of the call to
    /// `reduce(into:_:)`.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: An asynchronous closure that updates the accumulating
    ///     value with an element of the sequence.
    ///
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    @inlinable
    public func reduce<Result>(
        into initialResult: __owned Result,
        _ updateAccumulatingResult: (_ partialResult: inout Result, Element) async throws -> ()
    ) async rethrows -> Result {
        var accumulator = initialResult
        for element in self {
            try await updateAccumulatingResult(&accumulator, element)
        }
        return accumulator
    }
    
}

extension Sequence {
    
    /// Asynchronously creates an array containing the concatenated results of calling the
    /// given transformation with each element of this sequence.
    ///
    /// Use this method to receive a single-level collection when your
    /// transformation produces a sequence or collection for each element.
    ///
    /// In fact, `s.flatMap(transform)`  is equivalent to
    /// `Array(s.map(transform).joined())`.
    ///
    /// - Parameter transform: An asynchronous closure that accepts an element of this
    ///   sequence as its argument and returns a sequence or collection.
    ///
    /// - Returns: The resulting flattened array.
    @inlinable
    public func flatMap<SegmentOfResult: Sequence>(_ transform: (Element) async throws -> SegmentOfResult) async rethrows -> [SegmentOfResult.Element] {
        var result: [SegmentOfResult.Element] = []
        for element in self {
            result.append(contentsOf: try await transform(element))
        }
        return result
    }
    
}

extension Sequence {
    
    /// Asynchronously returns a Boolean value indicating whether the sequence contains an
    /// element that satisfies the given predicate.
    ///
    /// You can use the predicate to check for an element of a type that
    /// doesn't conform to the `Equatable` protocol.
    ///
    /// Alternatively, a predicate can be satisfied by a range of `Equatable`
    /// elements or a general condition.
    ///
    /// - Parameter predicate: An asynchronous closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element represents a match.
    ///
    /// - Returns: `true` if the sequence contains an element that satisfies
    ///   `predicate`; otherwise, `false`.
    @inlinable
    public func contains(where predicate: (Element) async throws -> Bool) async rethrows -> Bool {
        for e in self {
            if try await predicate(e) {
                return true
            }
        }
        return false
    }
    
    /// Asynchronously returns a Boolean value indicating whether every element of a sequence
    /// satisfies a given predicate.
    ///
    /// If the sequence is empty, this method returns `true`.
    ///
    /// - Parameter predicate: An asynchronous closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element satisfies a condition.
    ///
    /// - Returns: `true` if the sequence contains only elements that satisfy
    ///   `predicate`; otherwise, `false`.
    @inlinable
    public func allSatisfy(_ predicate: (Element) async throws -> Bool) async rethrows -> Bool {
        return try await !contains { try await !predicate($0) }
    }
}
