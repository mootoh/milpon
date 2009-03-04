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

- (NSArray *) modifiedTasks;
- (NSArray *) tasksForSQL:(NSString *)sql;

// TODO: lastSync should be moved to somewhere not here.
- (NSString *) lastSync;
- (void) updateLastSync;

+ (TaskProvider *) sharedTaskProvider;

#define RTMTASK_SQL_COLUMNS "id, name, url, due, priority, postponed, estimate, rrule, location_id, list_id, task_series_id, edit_bits"

// XXX: edit bits assumes 32 bit integer.
enum task_edit_bits_t {
   EB_TASK_DUE           = 1 << 1,
   EB_TASK_COMPLETED     = 1 << 2,
   EB_TASK_DELETED       = 1 << 3,
   EB_TASK_PRIORITY      = 1 << 4,
   EB_TASK_ESTIMATE      = 1 << 5,
   EB_TASK_NAME          = 1 << 6,
   EB_TASK_URL           = 1 << 7,
   EB_TASK_LOCACTION_ID  = 1 << 8,
   EB_TASK_LIST_ID       = 1 << 9,
   EB_TASK_RRULE         = 1 << 10
};

@end // TaskProvider
