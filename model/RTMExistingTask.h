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

@interface RTMExistingTask : RTMTask
{
   //NSNumber *task_series_id;
}

@property (nonatomic, retain) NSNumber *task_series_id;

+ (void) createOrUpdate:(NSDictionary *)task_series inDB:(RTMDatabase *)db;

@end
// set vim:ft=objc
