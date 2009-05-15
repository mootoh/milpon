/*
 *  TaskProvider.h
 *  Milpon
 *
 *  Created by mootoh on 3/05/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMTask;
@class RTMTag;
@class RTMNote;

@interface TaskProvider : NSObject

#pragma mark Task Collectors
- (NSArray *) tasks:(BOOL) showCompleted;
- (NSArray *) tasksInList:(NSInteger) list_id showCompleted:(BOOL) sc;
- (NSArray *) tasksInTag: (NSInteger) tag_id showCompleted:(BOOL) sc;
- (NSArray *) modifiedTasks;
- (NSArray *) pendingTasks;
//- (NSArray *) existingTasks;
//- (NSArray *) overDueTasks;
//- (NSArray *) todayTasks;
//- (NSArray *) tomorrowTasks;
//- (NSArray *) inAWeekTasks;

- (RTMTask *) taskForNote:(RTMNote *) note;

#pragma mark Create
/**
 * @return created task id
 */
- (NSNumber *) createAtOffline:(NSDictionary *)params;
- (void) createAtOnline:(NSDictionary *)params;
- (void) createOrUpdate:(NSDictionary *)params;
//- (void) sync;
- (void) erase;
- (void) remove:(RTMTask *) task;
//- (void) removeForID:(NSNumber *) task_id;
//- (BOOL) taskExist:(NSNumber *)idd;
//
//- (void) createNote:(NSString *)note task_id:(NSNumber *)tid;
//- (NSArray *) getNotes:(RTMTask *) task;
//- (void) removeNote:(NSNumber *) note_id;
//- (BOOL) noteExist:(NSNumber *)note_id;

+ (TaskProvider *) sharedTaskProvider;

@end // TaskProvider
