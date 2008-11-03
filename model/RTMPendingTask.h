
//
//  RTMPendingTask.h
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"
#import "RTMTask.h"

@class RTMDatabase;

@interface RTMPendingTask : RTMTask
{
}

- (id) initWithDB:(RTMDatabase *)ddb withParams:(NSDictionary *)params;

+ (void) createTask:(NSDictionary *)params inDB:(RTMDatabase *)db;
+ (NSArray *) allTasks:(RTMDatabase *)db;

@end
// set vim:ft=objc
