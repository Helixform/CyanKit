//
//  Created by Cyandev on 2022/10/20.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import CCyanUtils

public class MacrotaskQueue {
    
    public static let main: MacrotaskQueue = MacrotaskQueue(queue: CAKMacrotaskQueueGetMain())
    
    private let queue: OpaquePointer
    
    internal init(queue: OpaquePointer) {
        self.queue = queue
    }
    
    public func addTask(_ task: @convention(block) @escaping () -> Void) {
        CAKMacrotaskQueueAddTaskWithHandler(queue, task)
    }
    
}
