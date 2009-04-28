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

- (void) testTasksCount
{
   RTMList *lstZero = [[lp lists] objectAtIndex:0];
   STAssertEquals([lstZero taskCount], 1, @"task count check");
}

- (void) testTasks
{
   RTMList *lstZero = [[lp lists] objectAtIndex:0];

   NSArray *tasks = lstZero.tasks;
   STAssertEquals([tasks count], 1U, @"tasks should be 1.");
}

// should executed last
- (void) testZ999Erase
{
   [lp erase];
   STAssertEquals(lp.lists.count, 0U, @"lists should be erased to zero.");
}

// create in database
- (void) testZ998Create
{
   [lp erase];
   int before = lp.lists.count;

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:77], @"lucky seven", @"", nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [lp create:params];

   int after = lp.lists.count;
   STAssertEquals(after, before+1, @"1 element should be added");
}

/*
- (void) testSync
{
   ListProvider *lp = [ListProvider sharedListProvider];
   [lp sync];
}
*/

@end