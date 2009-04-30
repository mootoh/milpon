//
//  TaskTest.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMTask.h"
#import "TaskProvider.h"
#import "MilponHelper.h"

@interface TaskTest : SenTestCase
{
   TaskProvider *tp;
}
@end

@implementation TaskTest

- (void) setUp
{
   tp = [TaskProvider sharedTaskProvider];
}

- (void) testTasks
{
   NSArray *tasks = [tp tasks];
   STAssertEquals(tasks.count, 1U, @"should have some task elements.");
}

- (void) testPriority
{
   NSArray *tasks = [tp tasks];
   RTMTask *taskOne = [tasks objectAtIndex:0];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:0], @"priority check");
   STAssertEquals(taskOne.edit_bits, 0, @"edit bits should flagged up");

   taskOne.priority = [NSNumber numberWithInteger:1];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:1], @"priority changed");
   STAssertEquals(taskOne.edit_bits, EB_TASK_PRIORITY, @"edit bits should flagged up");
}

- (void) testAttributes
{
   NSArray *tasks = [tp tasks];
   STAssertEquals(tasks.count, 1U, @"should have some list elements.");

   RTMTask *first_task = [tasks objectAtIndex:0];

   STAssertEquals(first_task.iD, 1, @"check attr");

   STAssertTrue([first_task.name isEqualToString:@"task one"], @"check attr");
   STAssertTrue([first_task.url isEqualToString:@""], @"check attr");
   //STAssertTrue([first_task.due isEqualToDate:[[MilponHelper sharedHelper] stringToDate:@"2009-03-31 13:00:00"]], @"check attr");
   STAssertEquals([first_task.priority intValue], 0, @"check attr");
   STAssertEquals([first_task.postponed intValue], 0, @"check attr");
   STAssertTrue([first_task.estimate isEqualToString:@""], @"check attr");
   STAssertTrue([first_task.rrule isEqualToString:@""], @"check attr");
   STAssertEquals([first_task.list_id intValue], 1, @"check attr");
   STAssertEquals([first_task.location_id intValue], 1, @"check attr");
   STAssertEquals(first_task.edit_bits, 0, @"check attr");
#if 0
   STAssertTrue(first_task.tags.count > 0, @"check tags");
   NSString *tags = @"tag: ";
   for (NSString *tag in first_task.tags)
      tags = [tags stringByAppendingFormat:@"%@, ", tag];
   NSLog(tags);
#endif // 0
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