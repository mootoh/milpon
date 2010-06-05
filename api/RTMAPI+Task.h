//
//  RTMAPI+Task.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"

@interface RTMAPI (Task)

- (NSArray *) getTaskList;
- (NSArray *) getTaskList:(NSString *)inListID filter:(NSString *)filter lastSync:(NSString *)lastSync;

#if 0
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
#endif // 0
@end