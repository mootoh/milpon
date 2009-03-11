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
@class RTMTag;

@interface TaskProvider : NSObject

- (NSArray *) tasks;
- (NSArray *) tasksInList:(RTMList *)list;
- (NSArray *) tasksInTag:(RTMTag *)tag;
- (NSArray *) modifiedTasks;
- (NSArray *) existingTasks;

/**
 * @return created task id
 */
- (NSNumber *) createAtOffline:(NSDictionary *)params;
- (void) createAtOnline:(NSDictionary *)params;
- (void) sync;
- (void) erase;
- (void) complete:(RTMTask *)task;
- (void) uncomplete:(RTMTask *)task;
- (void) remove:(RTMTask *) task;

// TODO: lastSync should be moved to somewhere not here.
//- (NSString *) lastSync;
//- (void) updateLastSync;

+ (TaskProvider *) sharedTaskProvider;

@end // TaskProvider
