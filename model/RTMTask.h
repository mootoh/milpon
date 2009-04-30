//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMObject.h"
@class RTMNote;
@class RTMTag;

@interface RTMTask : RTMObject

#pragma mark properties

@property (nonatomic, readonly) NSNumber *task_id;
@property (nonatomic, readonly) NSNumber *taskseries_id;
@property (nonatomic, readonly) NSNumber *list_id;
@property (nonatomic, assign)   NSDate   *due;
@property (nonatomic, assign)   NSNumber *priority;
@property (nonatomic, assign)   NSString *name;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, assign)   NSDate   *completed;
@property (nonatomic, assign)   NSNumber *postponed;
@property (nonatomic, assign)   NSString *estimate;
//@property (nonatomic, retain) NSNumber *has_due_time;
@property (nonatomic, assign)   NSNumber *location_id;
@property (nonatomic, assign)   NSString *rrule;
@property (nonatomic, readonly) NSArray  *tags;
@property (nonatomic, readonly) NSArray  *notes;

#pragma mark methods
- (BOOL) is_completed;
//- (void) postpone;
//- (void) addNote: (RTMNote *) note;
//- (void) removeNote: (RTMNote *) note;
//- (void) addTag: (RTMTag *) tag;
//- (void) removeTag; (RTMTag *) tag;

- (void) complete;
- (void) uncomplete;

// XXX: edit bits assumes 32 bit integer.
enum task_edit_bits_t {
   EB_TASK_DUE           = 1 << 1,
   EB_TASK_COMPLETED     = 1 << 2,
   EB_TASK_PRIORITY      = 1 << 3,
   EB_TASK_ESTIMATE      = 1 << 4,
   EB_TASK_NAME          = 1 << 5,
   EB_TASK_LOCACTION_ID  = 1 << 6,
   EB_TASK_RRULE         = 1 << 7,
   EB_TASK_POSTPONED     = 1 << 8
};

@end