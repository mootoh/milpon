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
#import "MilponHelper.h"

@interface TaskProviderTest : SenTestCase
{
   TaskProvider *tp;
}
@end

@implementation TaskProviderTest

- (void) setUp
{
   tp = [TaskProvider sharedTaskProvider];
}

- (void) testTasks
{
}

#if 0
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
   STAssertEquals(tasks.count, 1U, @"should have some task elements in a index tag #1");
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
#endif // 0
@end