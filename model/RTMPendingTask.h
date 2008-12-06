
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

+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db;
+ (NSArray *) getNotes:(NSNumber *)task_id fromDB:(RTMDatabase *)db;
+ (void) removeNote:(NSNumber *)note_id fromDB:(RTMDatabase *)db;

@end
// set vim:ft=objc
