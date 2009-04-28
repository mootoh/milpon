//
//  RTMListTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMList.h"
#import "ListProvider.h"

@interface RTMListTest : SenTestCase
{
   ListProvider *lp;
}
@end

@implementation RTMListTest

- (void) setUp
{
   lp = [ListProvider sharedListProvider];
}

- (void) testCreate
{
   NSArray *keys = [NSArray arrayWithObjects:@"list.id", @"list.name", @"list.filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], @"list One", @"", nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   RTMList *list = [[RTMList alloc] initByAttributes:attrs];
   STAssertNotNil(list, @"list should be created");
   STAssertEquals(list.iD, 0, @"id check");
   STAssertEquals(list.name, @"list One", @"name check");
   STAssertEquals(list.filter, @"", @"filter check");
}

- (void) testAttribute
{
   RTMList *lstZero = [[lp lists] objectAtIndex:0];
   NSLog(@"lstOne id = %d, name = %@", lstZero.iD, lstZero.name);
}

#if 0
- (void) testTasks
{
   RTMList *list = [[RTMList alloc]
      initWithID:[NSNumber numberWithInt:1]
      forName:@"list one"];

   NSArray *tasks = list.tasks;
   STAssertEquals([tasks count], 3U, @"tasks should be 7.");
}
#endif // 0
@end