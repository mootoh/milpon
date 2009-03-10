//
//  TaskProviderTest.m
//  Milpon
//
//  Created by mootoh on 3/05/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TaskProvider.h"
#import "RTMTask.h"
#import "RTMList.h"
#import "RTMTag.h"

@interface TaskProviderTest : SenTestCase; @end

@implementation TaskProviderTest

- (void) testSingleton
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   STAssertNotNil(tp, @"should not be nil");
}

- (void) testTasks
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   NSArray *tasks = [tp tasks];
   STAssertEquals(tasks.count, 1U, @"should have some list elements.");

   RTMTask *first_task = [tasks objectAtIndex:0];

   STAssertEquals([first_task.iD intValue], 1, @"check attr");
   STAssertTrue([first_task.name isEqualToString:@"task one"], @"check attr");
   STAssertTrue([first_task.url isEqualToString:@"http://localhost/"], @"check attr");
   //STAssertTrue([first_task.due isEqualToDate:@"20090331"], @"check attr");
   STAssertEquals([first_task.priority intValue], 1, @"check attr");
   STAssertEquals([first_task.postponed intValue], 3, @"check attr");
   STAssertTrue([first_task.estimate isEqualToString:@"30m"], @"check attr");
   STAssertTrue([first_task.rrule isEqualToString:@""], @"check attr");
   STAssertEquals([first_task.list_id intValue], 1, @"check attr");
   STAssertEquals([first_task.location_id intValue], 1, @"check attr");
   STAssertEquals([first_task.edit_bits intValue], 0, @"check attr");

   STAssertTrue(first_task.tags.count > 0, @"check tags");
   for (NSString *tag in first_task.tags)
      NSLog(@"tag : %@", tag);
}

- (void) testTasksInList
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   RTMList *list = [[RTMList alloc] initWithID:[NSNumber numberWithInt:1] forName:@"list"];
   NSArray *tasks = [tp tasksInList:list];
   STAssertEquals(tasks.count, 1U, @"should have some list elements.");
}

- (void) testTasksInTags
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   RTMTag *tag = [[RTMTag alloc] initWithID:[NSNumber numberWithInt:1] forName:@"tag"];
   NSArray *tasks = [tp tasksInTag:tag];
   STAssertEquals(tasks.count, 1U, @"should have some list elements.");
}

#if 0
- (void) testComplete
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   RTMTask *task = [[RTMTask alloc] init];
   [tp complete:task];
   STAssertTrue([task is_completed], @"should be completed");
   [task release];

#if 0
   LocalCache *local_cache_ = [LocalCache sharedLocalCache];
   NSDictionary *dict = [NSDictionary dictionaryWithObject:@"1" forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
#endif // 0
}
#endif // 0

// - (void) testTasksInTask
// - (void) testSync

#if 0
- (void) testAdd
{
   TaskProvider *lp = [TaskProvider sharedTaskProvider];
   int before = lp.lists.count;
   [lp add:@"another element"];
   int after = lp.lists.count;
   STAssertEquals(before+1, after, @"1 element should be added");
}
#endif // 0
@end
