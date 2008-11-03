//
//  RTMExistingTask.h
//  Milpon
//
//  Created by mootoh on 11/03/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"
#import "RTMTask.h"

@class RTMDatabase;

@interface RTMExistingTask : RTMTask {
   NSNumber *task_series_id;
}

+ (NSArray *) tasks:(RTMDatabase *)db;
+ (NSArray *) tasksInList:(NSInteger)list_id inDB:(RTMDatabase *)db;
+ (NSArray *) completedTasks:(RTMDatabase *)db;

+ (void) create:(NSDictionary *)task_series inDB:(RTMDatabase *)db;
+ (void) createOrUpdate:(NSDictionary *)task_series inDB:(RTMDatabase *)db;

- (void) complete;
- (void) uncomplete;

- (BOOL) is_completed;

- (NSArray *) notes;

/* TODO
   + (void) erase;
   - (void) save;
   */

/* TODO
   + (void) add:(NSDictionary *) params;
   + (void) remove:(RTMTask *)aTask;
   */
@end
// set vim:ft=objc
