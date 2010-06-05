//
//  ListTest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI+Timeline.h"
#import "RTMAPI+List.h"
#import "RTMAPI.h"
#import "PrivateInfo.h"
#import "logger.h"

#define k_LIST_NAME_FOR_UNIT_TEST @"testAdd"

@interface RTMAPIListTest : SenTestCase
{
  RTMAPI *api;
}
@end

@implementation RTMAPIListTest

- (void) setUp
{
   api  = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;
}

- (void) tearDown
{
   api.token = nil;
   [api release];
}

- (void) testGetList
{
   NSArray *lists = [api getList];
	STAssertTrue([lists count] > 0, @"lists should be one or more.");
   LOG(@"lists = %@", lists);

   NSDictionary *listDict = [lists objectAtIndex:0];
   STAssertNotNil(listDict, nil);
   
   // check the list elements
   NSArray *keys = [NSArray arrayWithObjects:@"archived", @"deleted", @"id", @"locked", @"name", @"position", @"smart", @"sort_order", nil];

   for (NSDictionary *list in lists) {
      for (NSString *key in keys) {
         id val = [list objectForKey:key];
         STAssertNotNil(val, @"key is %@", key);
      }
   }
}

- (void) testAdd
{
   NSString *timeline = [api createTimeline];
   STAssertNotNil(timeline, nil);
   NSDictionary *addedList = [api add:k_LIST_NAME_FOR_UNIT_TEST timeline:timeline filter:nil];
   STAssertNotNil(addedList, nil);
   LOG(@"addedList = %@", addedList);
}

- (void) testAddAndDelete
{
	NSInteger count_first = [[api getList] count];

   // add
   NSString *timeline = [api createTimeline];
   NSDictionary *addedList = [api add:k_LIST_NAME_FOR_UNIT_TEST timeline:timeline filter:nil];
   NSString *addedListID = [addedList objectForKey:@"id"];
   
   // get lists for check added
	NSArray *lists = [api getList];
   NSInteger count_added = [lists count];
   STAssertEquals(count_added, count_first+1, @"lists count check");

   // check: is the added list in the lists ?
   BOOL found = NO;
   for (NSDictionary *list in lists) {
      if ([addedListID isEqualToString:[list objectForKey:@"id"]]) {
         found = YES;
         break;
      }
   }
   STAssertTrue(found, @"added list id existent check");

   // delete
   STAssertTrue([api delete:addedListID timeline:timeline], @"delete check");
   
   // get lists again for check deleted
	lists = [api getList];
   NSInteger count_deleted = [lists count];
   STAssertEquals(count_deleted, count_first, @"lists count check");
   
   // check: does new list no longer exist in lists ?
   found = NO;
   for (NSDictionary *list in lists) {
      if ([addedListID isEqualToString:[list objectForKey:@"id"]]) {
         found = YES;
         break;
      }
   }
   STAssertFalse(found, @"list id absense check");
}

- (void)testZZZ_Cleanup
{
   NSString *timeline = [api createTimeline];

	NSArray *lists = [api getList];
   STAssertNotNil(lists, nil);
   for (NSDictionary *list in lists) {
      if ([[list objectForKey:@"name"] isEqualToString:k_LIST_NAME_FOR_UNIT_TEST])
         STAssertTrue([api delete:[list objectForKey:@"id"] timeline:timeline], nil);
   }
}
@end