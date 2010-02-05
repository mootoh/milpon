//
//  RTMAPITask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMTask;

@interface RTMAPITask : NSObject {
  enum {
    // METHOD               ARGS
    TASKS_ADD,           // (list_id), name
    TASKS_ADD_TAGS,      // list_id,   taskseries_id, task_id, tags
    TASKS_COMPLETE,      // list_id,   taskseries_id, task_id
    TASKS_DELETE,        // list_id,   taskseries_id, task_id
    TASKS_GETLIST,       // (list_id),                         (filter), (last_sync)
    TASKS_MOVE_PRIORITY, // list_id,   taskseries_id, task_id, direction
    TASKS_MOVE_TO,       //            taskseries_id, task_id, from_list_id, to_list_id
    TASKS_POSTPONE,      // list_id,   taskseries_id, task_id
    TASKS_REMOVE_TAGS,   // list_id,   taskseries_id, task_id, tags
    TASKS_SET_DUE_DATE,  // list_id,   taskseries_id, task_id, (due), (has_due_time), (parse)
    TASKS_SET_ESTIMATE,  // list_id,   taskseries_id, task_id, (estimate)
    TASKS_SET_LOCATION,  // list_id,   taskseries_id, task_id, (location_id)
    TASKS_SET_NAME,      // list_id,   taskseries_id, task_id, name
    TASKS_SET_PRIORITY,  // list_id,   taskseries_id, task_id, (priority) 
    TASKS_SET_RECURRENCE,// list_id,   taskseries_id, task_id, (repeat) 
    TASKS_SET_TAGS,      // list_id,   taskseries_id, task_id, (tags) 
    TASKS_SET_URL,       // list_id,   taskseries_id, task_id, (url) 
    TASKS_UNCOMPLETE     // list_id,   taskseries_id, task_id
  } method;
}

- (NSArray *) getList;
- (NSArray *) getListForList:(NSString *)list_id;
- (NSArray *) getListWithLastSync:(NSString *)last_sync;
- (NSArray *) getListForList:(NSString *)list_id withLastSync:(NSString *)last_sync;
/**
 * @return [taskseries_id, task_id]
 */
- (NSDictionary *) add:(NSString *)name inList:(NSString *)list_id withTimeLine:(NSString *)timeLine;
- (BOOL) delete:(NSString *)task_id inTaskSeries:(NSString *)taskseries_id inList:(NSString *)list_id withTimeLine:(NSString *)timeLine;

- (BOOL) setDue:(NSString *)due forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) setLocation:(NSString *)location_id forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) setPriority:(NSString *)priority forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) setEstimate:(NSString *)estimate forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) complete:(RTMTask *)task withTimeLine:(NSString *)timeLine;
- (BOOL) setTags:(NSString *)tags forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) moveTo:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
- (BOOL) setName:(NSString *)name forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine;
@end
// vim:set ft=objc:
