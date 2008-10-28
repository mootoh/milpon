//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@class RTMDatabase;

@interface RTMTask : RTMStorable {
  NSString *name;
  NSString *url;
	NSString *due;
  NSString *location;
	NSString *completed;
	NSInteger priority;
	NSInteger postponed;
	NSString *estimate;
  NSInteger task_series_id;
}

@property (nonatomic) NSInteger iD;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *due;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *completed;
@property (nonatomic) NSInteger priority;
@property (nonatomic) NSInteger postponed;
@property (nonatomic, retain) NSString *estimate;

- (id) initWithDB:(RTMDatabase *)ddb withParams:(NSDictionary *)params;

+ (NSArray *) tasks:(RTMDatabase *)db;
+ (NSArray *) tasksInList:(NSInteger)list_id inDB:(RTMDatabase *)db;
+ (NSArray *) completedTasks:(RTMDatabase *)db;

+ (NSString *) lastSync:(RTMDatabase *)db;
+ (void) updateLastSync:(RTMDatabase *)db;

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
