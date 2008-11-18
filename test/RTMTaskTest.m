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

@interface RTMTaskTest : SenTestCase
@end

@implementation RTMTaskTest

- (void) testAliveTasks
{
  NSArray *alive_tasks = [RTMTask tasks];
	STAssertTrue(4 == [alive_tasks count], @"4 tasks should exist in list_id=2.");
}

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

@end
