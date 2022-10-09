//
//  Created by Cyandev on 2022/10/9.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import XCTest
@testable import CyanExtensions

@available(macOS 13.0, *)
fileprivate func fakeAsyncTransformer(_ input: Int) async throws -> String {
    try? await Task.sleep(for: .milliseconds(10))
    return "\(input)"
}

@available(macOS 13.0, *)
final class ConcurrencyAlgorithmsTests: XCTestCase {
    
    func testArrayMap() async {
        let input = [1, 2, 3, 4]
        do {
            let result = try await input.map(fakeAsyncTransformer)
            XCTAssertEqual(result, ["1", "2", "3", "4"])
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
        
        do {
            let result = try await [Int]().map(fakeAsyncTransformer)
            XCTAssertEqual(result, [])
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
}
