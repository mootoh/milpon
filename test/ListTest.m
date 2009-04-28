//
//  ListTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMList.h"
#import "ListProvider.h"

@interface ListTest : SenTestCase
{
   ListProvider *lp;
}
@end

@implementation ListTest

- (void) setUp
{
   lp = [ListProvider sharedListProvider];
}

- (void) testListsCount
{
   STAssertEquals(lp.lists.count, 5U, @"should have some list elements.");
}

// emulate create an instance from DB
- (void) testCreate
{
   NSArray *keys = [NSArray arrayWithObjects:@"list.id", @"list.name", @"list.filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], @"list One", @"", nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   RTMList *list = [[RTMList alloc] initByAttributes:attrs];
   STAssertNotNil(list, @"list should be created");
   STAssertEquals(list.iD, 0, @"id check");
   STAssertTrue([list.name isEqualTo:@"list One"], @"name check");
   STAssertTrue([list.filter isEqualTo:@""], @"filter check");
}

- (void) testAttribute
{
   NSArray *lists = [lp lists];
   RTMList *lstZero = [lists objectAtIndex:0];
   STAssertEquals(lstZero.iD, 1, @"id check");
   STAssertTrue([lstZero.name isEqualTo:@"Inbox"], @"name check");
   STAssertTrue([lstZero.filter isEqualTo:@""], @"filter check");
   STAssertFalse([lstZero isSmart], @"smart list check");

   RTMList *lstLast = [lists objectAtIndex:lists.count-1];
   STAssertEquals(lstLast.iD, 5, @"id check");
   STAssertTrue([lstLast.name isEqualTo:@"2007List"], @"name check");
   STAssertTrue([lstLast.filter isEqualTo:@"(tag:2007)"], @"filter check");
   STAssertTrue([lstLast isSmart], @"smart list check");
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

/*
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
 */

@end