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

@interface TaskProviderTest : SenTestCase; @end

@implementation TaskProviderTest

- (void) testCreate
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   STAssertNotNil(tp, @"should not be nil");
}

- (void) testComplete
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   RTMTask *task = [[RTMTask alloc] init];
   [tp complete:task];
   [task release];
}

#if 0
- (void) testTasks
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   STAssertTrue(tp.tasks.count > 0, @"should have some list elements.");
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
