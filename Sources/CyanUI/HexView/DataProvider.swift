//
//  Created by Cyandev on 2022/2/10.
//  Copyright © 2022 Cyandev. All rights reserved.
//

import Foundation

/// An abstraction for data-reading tasks that eliminates the need
/// to manage a raw memory buffer in the hex view.
public protocol HexViewDataProvider {
   
    /// An integer that indicates the length of the underlying data.
    var length: Int { get }
    
    /// Returns a byte at the given index.
    func byte(at index: Int) -> UInt8
    
}

/// A simple data provider implementation that use `Data` as backing store.
public struct HexViewDirectDataProvider: HexViewDataProvider {
    
    public let data: Data
    
    public init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        self.init(data: data)
    }
    
    public init(data: Data) {
        self.data = data
    }
    
    public var length: Int {
        return data.count
    }
    
    public func byte(at index: Int) -> UInt8 {
        return data[index]
    }
    
}
