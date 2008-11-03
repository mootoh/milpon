//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@class RTMDatabase;

@interface RTMTask : RTMStorable
{
   NSString *name;
   NSString *url;
   NSString *due;
   NSString *location;
   NSString *completed;
   NSNumber *priority;
   NSNumber *postponed;
   NSString *estimate;
   NSString *rrule;
   NSArray  *tags;
   NSArray  *notes;
   NSNumber *list_id;
   NSNumber *location_id;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *due;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *completed;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *postponed;
@property (nonatomic, retain) NSString *estimate;
@property (nonatomic, retain) NSString *rrule;
@property (nonatomic, retain) NSArray  *tags;
@property (nonatomic, retain) NSArray  *notes;
@property (nonatomic, retain) NSNumber *list_id;
@property (nonatomic, retain) NSNumber *location_id;

- (void) complete;
- (void) uncomplete;
- (BOOL) is_completed;


+ (NSArray *) tasks:(RTMDatabase *)db;
+ (NSArray *) tasksInList:(NSNumber *)list_id inDB:(RTMDatabase *)db;
+ (NSArray *) completedTasks:(RTMDatabase *)db;

+ (void) createOrUpdate:(NSDictionary *)task_series inDB:(RTMDatabase *)db;
+ (void) createPendingTask:(NSDictionary *)params inDB:(RTMDatabase *)db;

// TODO: lastSync should be moved to somewhere not here.
+ (NSString *) lastSync:(RTMDatabase *)db;
+ (void) updateLastSync:(RTMDatabase *)db;

@end
// set vim:ft=objc
