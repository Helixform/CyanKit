//
//  Created by ktiays on 2021/12/5.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation
import Combine

fileprivate class _ReplayPublisherBuffer<O, E> where E: Error {
    
    let upstreamPublisher: AnyPublisher<O, E>
    let lock = NSLock()
    var buffer = [O]()
    var cancellable: AnyCancellable?
    
    init(_ upstreamPublisher: AnyPublisher<O, E>) {
        self.upstreamPublisher = upstreamPublisher
        
        cancellable = upstreamPublisher.sink { _ in } receiveValue: { [weak self] item in
            self?.withBuffer { items in
                items.append(item)
            }
        }
    }
    
    func withBuffer(_ action: (inout [O]) -> ()) {
        lock.lock()
        action(&buffer)
        lock.unlock()
    }
    
}

fileprivate class _ReplayPublisherSubscription<O, E>: Subscription where E: Error {
    
    var cancellable: AnyCancellable? = nil
    
    init<S>(subscriber: S, buffer: _ReplayPublisherBuffer<O, E>)
        where S: Subscriber, S.Input == O, S.Failure == E
    {
        subscriber.receive(subscription: self)
        buffer.withBuffer { items in
            for item in items {
                let _ = subscriber.receive(item)
            }
            let cancellable = buffer.upstreamPublisher.sink { _ in } receiveValue: { item in
                let _ = subscriber.receive(item)
            }
            self.cancellable = cancellable
        }
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() { }
    
}

struct ReplayPublisher<O, E>: Publisher where E: Error {
    
    typealias Output = O
    typealias Failure = E
    
    private let buffer: _ReplayPublisherBuffer<O, E>
    
    init<P>(_ upstreamPublisher: P) where P: Publisher, P.Output == O, P.Failure == E {
        self.buffer = .init(upstreamPublisher.eraseToAnyPublisher())
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, E == S.Failure, O == S.Input {
        let _ = _ReplayPublisherSubscription(subscriber: subscriber, buffer: buffer)
    }
    
}
