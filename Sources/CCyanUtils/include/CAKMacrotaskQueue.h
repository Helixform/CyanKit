//
//  Created by Cyandev on 2022/10/20.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

#ifndef CAKMacrotaskQueue_h
#define CAKMacrotaskQueue_h

typedef struct _CAKMacrotaskQueue CAKMacrotaskQueue;

extern CAKMacrotaskQueue *CAKMacrotaskQueueGetMain(void);

extern void CAKMacrotaskQueueAddTaskWithHandler(CAKMacrotaskQueue *queue, void (^block)(void));

#endif /* CAKMacrotaskQueue_h */
