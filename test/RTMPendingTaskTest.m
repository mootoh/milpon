//
//  RTMPendingTaskTest.m
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMPendingTask.h"
#import "RTMDatabase.h"

@interface RTMPendingTaskTest : SenTestCase {
	RTMDatabase *db;
}
@end

@implementation RTMPendingTaskTest

- (void) setUp {
	db = [[RTMDatabase alloc] init];
}

- (void) tearDown {
	[db release];
}

- (void) testAllTasks {
	NSArray *tasks = [RTMPendingTask allTasks:db];
	STAssertTrue(0 == [tasks count], @"no pending tasks.");
}

- (void) testCreateTask {
    NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"location_id", @"list_id", @"priority", @"estimate", nil];
    NSArray *vals = [NSArray arrayWithObjects:@"1", @"one", @"http://localhost/", @"2008-10-15T10:00:00", @"0", @"1", @"0", @"", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

  [RTMPendingTask createTask:params inDB:db];

	NSArray *tasks = [RTMPendingTask allTasks:db];
	STAssertTrue(1 == [tasks count], @"a pending task created.");

  //RTMPendingTask *task = [[[RTMPendingTask alloc] initWithDB:db withParams:params] autorelease];
}

/*
- (void) testTaskWithListID {
	NSArray *tasks = [RTMTask tasksInList:1];
	STAssertTrue(5 == [tasks count], @"5 tasks should exist in list_id=1.");
}

- (void) testTaskProperties {
  NSArray *tasks = [RTMTask tasksInList:2];
	STAssertTrue(2 == [tasks count], @"2 tasks should exist in list_id=2.");

  RTMTask *task = [tasks objectAtIndex:0];
  STAssertTrue([task.name isEqualToString:@"Forget about it"], @"check task name");
}
*/

@end
