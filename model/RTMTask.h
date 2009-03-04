//
//  RTMTask.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

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

- (id) initByParams:(NSDictionary *)params;

- (void) complete;
- (void) uncomplete;
- (BOOL) is_completed;

- (void) flagUpEditBits:(enum task_edit_bits_t) flag;
- (void) flagDownEditBits:(enum task_edit_bits_t) flag;

@end
// set vim:ft=objc
