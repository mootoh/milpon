//
//  MPTask.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MPTask : NSManagedObject

enum {
   EDIT_BITS_TASKSERIES_NONE     = 0,
   EDIT_BITS_TASKSERIES_CREATED  = 1 << 0,
   EDIT_BITS_TASKSERIES_NAME     = 1 << 1,
   EDIT_BITS_TASKSERIES_RRULE    = 1 << 2,
   EDIT_BITS_TASKSERIES_LIST     = 1 << 3,
   EDIT_BITS_TASKSERIES_LOCATION = 1 << 4,
   EDIT_BITS_TASKSERIES_TAGS     = 1 << 5
};

enum {
   EDIT_BITS_TASK_NONE         = 0,
   EDIT_BITS_TASK_DELETED      = 1 << 0,
   EDIT_BITS_TASK_COMPLETION   = 1 << 1,
   EDIT_BITS_TASK_DUE_DATE     = 1 << 2,
   EDIT_BITS_TASK_DUE_TIME     = 1 << 3,
   EDIT_BITS_TASK_HAS_DUE_TIME = 1 << 4,
   EDIT_BITS_TASK_ESTIMATE     = 1 << 5,
   EDIT_BITS_TASK_POSTPONED    = 1 << 6,
   EDIT_BITS_TASK_PRIORITY     = 1 << 7
};

- (NSString *) is_completed;

- (void) complete;
- (void) uncomplete;

@end