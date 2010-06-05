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
- (NSArray *) getTaskList:(NSString *)inListID filter:(NSString *)filter lastSync:(NSString *)lastSync;
/**
 * @return added TaskSereis.
 */
- (NSDictionary *) addTask:(NSString *)name list_id:(NSString *)list_id timeline:(NSString *)timeline;
- (BOOL) deleteTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeLine;

#if 0
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