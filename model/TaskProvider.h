/*
 *  TaskProvider.h
 *  Milpon
 *
 *  Created by mootoh on 3/05/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMTask;
@class RTMList;

@interface TaskProvider : NSObject

- (NSArray *) tasks;
- (NSArray *) tasksInList:(RTMList *)list;
- (NSArray *) modifiedTasks;

- (void) sync;

- (void) complete:(RTMTask *)task;

// TODO: lastSync should be moved to somewhere not here.
//- (NSString *) lastSync;
//- (void) updateLastSync;

+ (TaskProvider *) sharedTaskProvider;

@end // TaskProvider
