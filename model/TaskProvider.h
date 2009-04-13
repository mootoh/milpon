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
@class RTMNote;

@interface TaskProvider : NSObject

- (NSArray *) tasks;
- (NSArray *) tasksInList:(RTMList *)list;
- (NSArray *) tasksInTag:(RTMTag *)tag;
- (NSArray *) modifiedTasks;
- (NSArray *) pendingTasks;
- (NSArray *) existingTasks;

/**
 * @return created task id
 */
- (NSNumber *) createAtOffline:(NSDictionary *)params;
- (void) createAtOnline:(NSDictionary *)params;
- (void) createOrUpdate:(NSDictionary *)params;
- (void) sync;
- (void) erase;
- (void) complete:(RTMTask *)task;
- (void) uncomplete:(RTMTask *)task;
- (void) remove:(RTMTask *) task;
- (void) removeForID:(NSNumber *) task_id;
- (BOOL) taskExist:(NSNumber *)idd;
- (void) updateTask:(NSDictionary *)task inTaskSeries:(NSDictionary *)taskseries;

- (void) createNote:(NSString *)note task_id:(NSNumber *)tid;
- (NSArray *) getNotes:(RTMTask *) task;
- (void) removeNote:(NSNumber *) note_id;

+ (TaskProvider *) sharedTaskProvider;

@end // TaskProvider
