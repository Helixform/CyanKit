//
//  Created by Cyandev on 2022/10/20.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

#include <os/lock.h>
#include <pthread/pthread.h>
#include <dispatch/dispatch.h>
#include <CoreFoundation/CoreFoundation.h>

#include "CAKMacrotaskQueue.h"

typedef struct _CAKMacrotask {
    void *info;
    void (^block)(void);
    struct _CAKMacrotask *nextTask;
} CAKMacrotask;

typedef struct _CAKMacrotaskQueue {
    CAKMacrotask *headTask;
    CAKMacrotask *tailTask;
    CFRunLoopSourceRef source;
    CFRunLoopRef rl;
    os_unfair_lock lock;
} CAKMacrotaskQueue;

static __inline__
CAKMacrotask *CAKMacrotaskCreateWithHandler(void (^block)(void)) {
    CAKMacrotask *task = malloc(sizeof(CAKMacrotask));
    task->info = NULL;
    task->block = Block_copy(block);
    task->nextTask = NULL;
    return task;
}

static __inline__ void CAKMacrotaskFree(CAKMacrotask *task) {
    Block_release(task->block);
    free(task);
}

static void __attribute__((noinline))
__CAKMACROTASKQUEUE_IS_CALLING_OUT_TO_A_TASK_BLOCK__(CAKMacrotask *task) {
    task->block();
}

static CAKMacrotaskQueue *sQueue = NULL;

static void __CAKMacrotaskQueuePokeRunLoop(CAKMacrotaskQueue *queue);

static CAKMacrotask *__CAKMacrotaskQueuePopTask(CAKMacrotaskQueue *queue) {
    os_unfair_lock_lock(&queue->lock);
    CAKMacrotask *task = queue->headTask;
    if (__builtin_expect(!task, false)) {  // cold-path
        os_unfair_lock_unlock(&queue->lock);
        return NULL;
    }
    CAKMacrotask *nextTask = task->nextTask;
    queue->headTask = nextTask;
    if (__builtin_expect(!nextTask, false)) {  // cold-path
        queue->tailTask = NULL;
    }
    os_unfair_lock_unlock(&queue->lock);
    
    return task;
}

#define RUNLOOP_DEADLINE 0.016

static void __CAKMacrotaskQueueDrainUntilDeadline(CAKMacrotaskQueue *queue) {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    while ((CFAbsoluteTimeGetCurrent() - startTime) < RUNLOOP_DEADLINE) {
        CAKMacrotask *task = __CAKMacrotaskQueuePopTask(queue);
        if (__builtin_expect(!task, false)) {
            return;
        }
        __CAKMACROTASKQUEUE_IS_CALLING_OUT_TO_A_TASK_BLOCK__(task);
        CAKMacrotaskFree(task);
    }
    
    // We may still have remaining tasks to execute, signal the runloop
    // for the next loop.
    __CAKMacrotaskQueuePokeRunLoop(queue);
}

static void __CAKMacrotaskRunloopObserverCallback(CFRunLoopObserverRef observer,
                                                  CFRunLoopActivity activity,
                                                  void *info) {
    CAKMacrotaskQueue *queue = (CAKMacrotaskQueue *) info;
    __CAKMacrotaskQueueDrainUntilDeadline(queue);
}

static void __CAKMacrotaskQueueInitMain() {
    CAKMacrotaskQueue *queue = malloc(sizeof(CAKMacrotaskQueue));
    queue->headTask = NULL;
    queue->tailTask = NULL;
    queue->lock = OS_UNFAIR_LOCK_INIT;
    
    CFRunLoopRef rl = CFRunLoopGetMain();
    queue->rl = rl;
    
    CFRunLoopSourceContext ctx;
    ctx.version = 0;
    ctx.info = NULL;
    ctx.retain = NULL;
    ctx.release = NULL;
    ctx.copyDescription = NULL;
    ctx.equal = NULL;
    ctx.hash = NULL;
    ctx.schedule = NULL;
    ctx.cancel = NULL;
    ctx.perform = NULL;
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(NULL, 0, &ctx);
    queue->source = source;
    CFRunLoopAddSource(rl, source, kCFRunLoopCommonModes);
    
    CFRunLoopObserverContext obCtx;
    obCtx.version = 0;
    obCtx.info = queue;
    obCtx.retain = NULL;
    obCtx.release = NULL;
    obCtx.copyDescription = NULL;
    CFRunLoopObserverRef observer =
    CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, true, 0,
                            __CAKMacrotaskRunloopObserverCallback, &obCtx);
    CFRunLoopAddObserver(rl, observer, kCFRunLoopCommonModes);
    
    sQueue = queue;
}

static void __CAKMacrotaskQueuePokeRunLoop(CAKMacrotaskQueue *queue) {
    CFRunLoopSourceSignal(queue->source);
    CFRunLoopWakeUp(queue->rl);
}

CAKMacrotaskQueue *CAKMacrotaskQueueGetMain() {
    if (__builtin_expect(sQueue != NULL, true)) {
        return sQueue;
    }
    
    if (pthread_main_np()) {
        __CAKMacrotaskQueueInitMain();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            __CAKMacrotaskQueueInitMain();
        });
    }
    
    return sQueue;
}

void CAKMacrotaskQueueAddTaskWithHandler(CAKMacrotaskQueue *queue, void (^block)(void)) {
    CAKMacrotask *task = CAKMacrotaskCreateWithHandler(block);
    
    os_unfair_lock_lock(&queue->lock);
    if (__builtin_expect(!queue->headTask, false)) {
        // The queue is empty, enqueue the first task.
        queue->headTask = task;
        queue->tailTask = task;
    } else {
        queue->tailTask->nextTask = task;
        queue->tailTask = task;
    }
    os_unfair_lock_unlock(&queue->lock);
    
    __CAKMacrotaskQueuePokeRunLoop(queue);
}
