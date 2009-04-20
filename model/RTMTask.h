//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@interface RTMTask : NSObject
{
   NSNumber *iD;
   NSNumber *edit_bits;
   // Task
   NSNumber *task_id;
   NSDate   *due;
   NSDate   *completed;
   NSNumber *priority;
   NSNumber *postponed;
   NSString *estimate;
   NSNumber *has_due_time;
   // TaskSeries
   NSNumber *taskseries_id;
   NSString *name;
   NSString *url;
   NSNumber *location_id;
   NSNumber *list_id;
   NSString *rrule;

   NSMutableArray *tags;
   NSMutableArray *notes;
}

@property (nonatomic, retain) NSNumber *iD;
@property (nonatomic, retain) NSNumber *edit_bits;

@property (nonatomic, retain) NSNumber *task_id;
@property (nonatomic, retain) NSDate   *due;
@property (nonatomic, retain) NSDate   *completed;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *postponed;
@property (nonatomic, retain) NSString *estimate;
@property (nonatomic, retain) NSNumber *has_due_time;

@property (nonatomic, retain) NSNumber *taskseries_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSNumber *location_id;
@property (nonatomic, retain) NSNumber *list_id;
@property (nonatomic, retain) NSString *rrule;

@property (nonatomic, retain) NSArray  *tags;
@property (nonatomic, retain) NSArray  *notes;

- (id) initByParams:(NSDictionary *)params;

- (void) complete;
- (void) uncomplete;
- (BOOL) is_completed;

- (void) flagUpEditBits:(enum task_edit_bits_t) flag;
- (void) flagDownEditBits:(enum task_edit_bits_t) flag;

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
   EB_TASK_RRULE         = 1 << 10,
   EB_TASK_NOTE          = 1 << 11,
};

@end
// set vim:ft=objc
