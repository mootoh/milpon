//
//  RTMAPI+Task.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"

@interface RTMAPI (Task)

/**
 * @return array of TaskSeries, each has associated list_id.
 */
- (NSArray *) getTaskList;
- (NSArray *) getTaskList:(NSString *)lastSync;
- (NSArray *) getTaskList:(NSString *)inListID filter:(NSString *)filter lastSync:(NSString *)lastSync;

/**
 * @return added TaskSereis.
 */
- (NSDictionary *) addTask:(NSString *)name list_id:(NSString *)list_id timeline:(NSString *)timeline;

- (void) deleteTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeLine;
- (void) setTaskDueDate:(NSString *)due timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id has_due_time:(BOOL)has_due_time parse:(BOOL)parse;
- (void) setTaskLocation:(NSString *)location_id timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;
- (void) setTaskPriority:(NSString *)priority timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;
- (void) setTaskEstimate:(NSString *)estimate timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;
- (void) completeTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeline;
- (void) setTaskTags:(NSString *)tags task_id:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeline;
- (void) moveTaskTo:(NSString *)to_list_id from_list_id:(NSString *)from_list_id task_id:(NSString *)task_id taskseries_id:(NSString *)taskseries_id  timeline:(NSString *)timeline;
- (void) setTaskName:(NSString *)name timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;
- (void) setRecurrence:(NSString *)recurrence timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;

@end