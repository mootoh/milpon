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

- (void) test00Singleton
{
   ListProvider *lp = [ListProvider sharedListProvider];
   STAssertNotNil(lp, @"should not be nil");
}

- (void) test01Lists
{
   ListProvider *lp = [ListProvider sharedListProvider];
   STAssertTrue(lp.lists.count > 0, @"should have some list elements.");
}

#if 0
- (void) testSync
{
   ListProvider *lp = [ListProvider sharedListProvider];
   [lp sync];
}
#endif // 0

- (void) testErase
{
   ListProvider *lp = [ListProvider sharedListProvider];
   [lp erase];
   STAssertEquals(lp.lists.count, 0U, @"lists should be erased to zero.");
}

- (void) testCreate
{
   ListProvider *lp = [ListProvider sharedListProvider];

   [lp erase];
   int before = lp.lists.count;

   NSArray *keys = [NSArray arrayWithObjects:@"iD", @"name", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:77], @"lucky seven", nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [lp create:params];

   int after = lp.lists.count;
   STAssertEquals(after, before+1, @"1 element should be added");
}
@end
