//
//  ListProviderTest.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ListProvider.h"

@interface ListProviderTest : SenTestCase
{   
   ListProvider *lp;
}

@end

@implementation ListProviderTest

- (void) setUp
{
   lp = [[ListProvider sharedListProvider] retain];
}

- (void) tearDown
{
   [lp release];
}

- (void) testCreate
{
   STAssertNotNil(lp, @"should not be nil");
}

- (void) testLists
{
   STAssertTrue(lp.lists.count > 0, @"should have some list elements.");
}

- (void) testAdd
{
   int before = lp.lists.count;
   [lp add:@"another element"];
   int after = lp.lists.count;
   STAssertEquals(before+1, after, @"1 element should be added");
}
@end
