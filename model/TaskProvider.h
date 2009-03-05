/*
 *  TaskProvider.h
 *  Milpon
 *
 *  Created by mootoh on 3/05/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMTask;

@interface TaskProvider : NSObject

- (NSArray *) tasks;
- (NSArray *) tasksInList:(NSNumber *)list_id;
- (void) add:(NSString *)elm;
- (void) sync;

- (void) complete:(RTMTask *)task;

- (NSArray *) modifiedTasks;
- (NSArray *) tasksForSQL:(NSString *)sql;

// TODO: lastSync should be moved to somewhere not here.
- (NSString *) lastSync;
- (void) updateLastSync;

+ (TaskProvider *) sharedTaskProvider;

#define RTMTASK_SQL_COLUMNS "id, name, url, due, priority, postponed, estimate, rrule, location_id, list_id, task_series_id, edit_bits"

@end // TaskProvider
