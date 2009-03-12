//
//  RTMExistingTask.h
//  Milpon
//
//  Created by mootoh on 11/03/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"
#import "RTMTask.h"

@interface RTMExistingTask : RTMTask
{
   //NSNumber *taskseries_id; // TODO
}

@property (nonatomic, retain) NSNumber *taskseries_id;

+ (void) createOrUpdate:(NSDictionary *)taskseries;

@end
// set vim:ft=objc
