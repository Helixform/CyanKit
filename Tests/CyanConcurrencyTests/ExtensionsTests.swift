//
//  Created by Cyandev on 2022/10/9.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import XCTest
@testable import CyanConcurrency

@available(macOS 13.0, iOS 16.0, *)
fileprivate func fakeAsyncTransformer(_ input: Int) async -> String {
    try? await Task.sleep(for: .milliseconds(10))
    return "\(input)"
}

@available(macOS 13.0, iOS 16.0, *)
fileprivate func fakeAsyncTransformerThrows(_ input: Int) async throws -> String {
    if input % 2 == 0 {
        struct _DummyError: Error { }
        throw _DummyError()
    }
    return await fakeAsyncTransformer(input)
}

@available(macOS 13.0, iOS 16.0, *)
final class ConcurrencyAlgorithmsTests: XCTestCase {
    
    func testArrayMap() async {
        // Test normal use case:
        let input = [1, 2, 3, 4]
        let result = await input.mapAsync(fakeAsyncTransformer)
        XCTAssertEqual(result, ["1", "2", "3", "4"])
        
        // Test empty optimization:
        let result2 = await [Int]().mapAsync(fakeAsyncTransformer)
        XCTAssertEqual(result2, [])
        
        // Test error handling for transformer errors:
        do {
            let _ = try await input.mapAsync(fakeAsyncTransformerThrows)
            XCTFail("Should not reach here.")
        } catch {
            // Expected path.
        }
    }
    
}
