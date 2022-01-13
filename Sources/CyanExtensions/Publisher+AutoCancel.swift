//
//  Created by ktiays on 2022/1/8.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Combine

fileprivate class _CancellableHolder: Cancellable {
    
    var cancellable: AnyCancellable?
    
    func cancel() {
        cancellable = nil
    }
    
}

public extension Publisher {
    
    var cyan: PublisherExtensionNamespace<Self> {
        return .init(extendedObject: self)
    }
    
}

public struct PublisherExtensionNamespace<T> where T: Publisher {
    
    fileprivate let extendedObject: T
    
    @discardableResult public func sinkOnce(
        receiveCompletion: @escaping ((Subscribers.Completion<T.Failure>) -> Void),
        receiveValue: @escaping ((T.Output) -> Void)
    ) -> Cancellable {
        let cancellableHolder = _CancellableHolder()
        cancellableHolder.cancellable = extendedObject.sink {
            receiveCompletion($0)
            cancellableHolder.cancel()
        } receiveValue: {
            receiveValue($0)
            cancellableHolder.cancel()
        }
        return cancellableHolder
    }
    
    @discardableResult public func sinkOnce(receiveValue: @escaping ((T.Output) -> Void)) -> Cancellable {
        return sinkOnce { _ in } receiveValue: {
            receiveValue($0)
        }
    }
    
}
