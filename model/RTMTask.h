//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

#define RTMTASK_SQL_COLUMNS "id, name, url, due, priority, postponed, estimate, rrule, location_id, list_id, task_series_id, edit_bits"

@class RTMDatabase;

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

@interface RTMTask : RTMStorable
{
   NSString *name;
   NSString *url;
   NSString *due;
   NSString *completed;
   NSNumber *priority;
   NSNumber *postponed;
   NSString *estimate;
   NSString *rrule;
   NSArray  *tags;
   NSArray  *notes;
   NSNumber *list_id;
   NSNumber *location_id;
   NSNumber *edit_bits;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *due;
@property (nonatomic, retain) NSString *completed;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *postponed;
@property (nonatomic, retain) NSString *estimate;
@property (nonatomic, retain) NSString *rrule;
@property (nonatomic, retain) NSArray  *tags;
@property (nonatomic, retain) NSArray  *notes;
@property (nonatomic, retain) NSNumber *list_id;
@property (nonatomic, retain) NSNumber *location_id;
@property (nonatomic, retain) NSNumber *edit_bits;

- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb;

- (void) complete;
- (void) uncomplete;
- (BOOL) is_completed;

- (void) flagUpEditBits:(enum task_edit_bits_t) flag;
- (void) flagDownEditBits:(enum task_edit_bits_t) flag;


+ (NSArray *) tasks:(RTMDatabase *)db;
+ (NSArray *) tasksInList:(NSNumber *)list_id inDB:(RTMDatabase *)db;
+ (NSArray *) modifiedTasks:(RTMDatabase *)db;

+ (NSArray *) tasksForSQL:(NSString *)sql inDB:(RTMDatabase *)db;

// TODO: lastSync should be moved to somewhere not here.
+ (NSString *) lastSync:(RTMDatabase *)db;
+ (void) updateLastSync:(RTMDatabase *)db;

@end
// set vim:ft=objc
