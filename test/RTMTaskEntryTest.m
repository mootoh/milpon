//
//  RTMTaskEntryTest.m
//  RTM4iPhone
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMTaskEntry.h"

@interface RTMTaskEntryTest : SenTestCase
@end

@implementation RTMTaskEntryTest

- (void) testAllTasks
{
  NSArray *tasks = [RTMTaskEntry allTasks];
  STAssertTrue(0 < [tasks count], @"tasks should have elements");
	RTMTaskEntry *task;
	for (task in tasks) {
		NSLog(@"task iD = %d, due=%@", task.iD, task.due);
	}
}

@end
