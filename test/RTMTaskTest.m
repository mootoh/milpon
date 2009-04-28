//
//  RTMTaskTest.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMTask.h"
#import "TaskProvider.h"

@interface RTMTaskTest : SenTestCase
@end

@implementation RTMTaskTest

- (void) testTasks
{
   NSArray *tasks = [[TaskProvider sharedTaskProvider] tasks];
   STAssertEquals(tasks.count, 1U, @"should have some task elements.");
}

- (void) testPriority
{
   NSArray *tasks = [[TaskProvider sharedTaskProvider] tasks];
   RTMTask *taskOne = [tasks objectAtIndex:0];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:0], @"priority check");
   STAssertEquals(taskOne.edit_bits, 0, @"edit bits should flagged up");

   taskOne.priority = [NSNumber numberWithInteger:1];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:1], @"priority changed");
   STAssertEquals(taskOne.edit_bits, EB_TASK_PRIORITY, @"edit bits should flagged up");
}

#if 0
- (void) testAllTasks
{
   NSArray *tasks = [RTMTask allTasks];
   STAssertTrue(7 == [tasks count], @"7 tasks should exist.");
}

- (void) testTaskWithListID
{
   NSArray *tasks = [RTMTask tasksInList:1];
   STAssertTrue(5 == [tasks count], @"5 tasks should exist in list_id=1.");
}

- (void) testTaskProperties
{
   NSArray *tasks = [RTMTask tasksInList:2];
   STAssertTrue(2 == [tasks count], @"2 tasks should exist in list_id=2.");

   RTMTask *task = [tasks objectAtIndex:0];
   STAssertTrue([task.name isEqualToString:@"Forget about it"], @"check task name");
}
#endif
@end