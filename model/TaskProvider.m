//
//  TaskProvider.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TaskProvider.h"

@implementation TaskProvider

- (NSArray *) tasks
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) tasksInList:(RTMList *)list
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) modifiedTasks
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) existingTasks;
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (void) createAtOffline:(NSDictionary *)params;
{
   NSAssert(NO, @"not reach here");
}

- (void) sync
{
   NSAssert(NO, @"not reach here");
}

- (void) complete:(RTMTask *)task
{
   NSAssert(NO, @"not reach here");
}

- (void) uncomplete:(RTMTask *)task;
{
   NSAssert(NO, @"not reach here");
}

- (void) remove:(RTMTask *) task;
{
   NSAssert(NO, @"not reach here");
}

+ (TaskProvider *) sharedTaskProvider
{
   NSAssert(NO, @"not reach here");
   return nil;
}

@end
