//
//  ListProviderTest.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ListProvider.h"

@interface ListProviderTest : SenTestCase; @end

@implementation ListProviderTest

- (void) testCreate
{
   ListProvider *lp = [ListProvider sharedListProvider];
   STAssertNotNil(lp, @"should not be nil");
}

- (void) testLists
{
   ListProvider *lp = [ListProvider sharedListProvider];
   STAssertTrue(lp.lists.count > 0, @"should have some list elements.");
}

// - (void) testTasksInList
// - (void) testSync

#if 0
- (void) testAdd
{
   ListProvider *lp = [ListProvider sharedListProvider];
   int before = lp.lists.count;
   [lp add:@"another element"];
   int after = lp.lists.count;
   STAssertEquals(before+1, after, @"1 element should be added");
}
#endif // 0
@end
