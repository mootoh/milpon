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
#import "MPLogger.h"

#define k_LIST_NAME_FOR_UNIT_TEST @"testAdd"

@interface RTMAPIListTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;
   NSDictionary *createdList;
}
@end

@implementation RTMAPIListTest

- (void) setUp
{
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;
   createdList = nil;
   timeline = [api createTimeline];
   STAssertNotNil(timeline, nil);
}

- (void) tearDown
{
   if (createdList) {
      NSString *listID = [createdList objectForKey:@"id"];
      [api deleteList:listID timeline:timeline];

      // get lists again to check if the list is absolutely deleted.
      NSArray *lists = [api getList];
      BOOL found = NO;
      for (NSDictionary *list in lists) {
         if ([listID isEqualToString:[list objectForKey:@"id"]]) {
            found = YES;
            break;
         }
      }
      STAssertFalse(found, @"list id absense check");
   }

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

- (void) addList
{
   createdList = [api addList:k_LIST_NAME_FOR_UNIT_TEST timeline:timeline filter:nil];
}

- (void) testAdd
{
	NSInteger count_first = [[api getList] count];

   // add
   [self addList];
   NSString *addedListID = [createdList objectForKey:@"id"];
   
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
}

- (void) testSetName
{
   NSString *listNameForRenaming = @"renamed";

   // add
   [self addList];

   // rename
   NSDictionary *renamedList = [api setListName:listNameForRenaming list:[createdList objectForKey:@"id"] timeline:timeline];
   STAssertTrue([listNameForRenaming isEqualToString:[renamedList objectForKey:@"name"]], nil);
}

- (void) testArchiveAndUnArchive
{
   // add
   [self addList];
   NSString *listID = [createdList objectForKey:@"id"];

   // archive
   STAssertTrue([api archiveList:listID timeline:timeline], nil);

   // get lists for check added
	NSArray *lists = [api getList];

   // check: is the added list in the lists ?
   BOOL found = NO;
   for (NSDictionary *list in lists) {
      if ([listID isEqualToString:[list objectForKey:@"id"]]) {
         found = YES;

         STAssertTrue([[list objectForKey:@"archived"] isEqualToString:@"1"], nil);
         break;
      }
   }
   STAssertTrue(found, nil);

   // unarchive
   STAssertTrue([api unarchiveList:listID timeline:timeline], nil);

   // get lists for check added
	lists = [api getList];

   // check: is the added list in the lists ?
   found = NO;
   for (NSDictionary *list in lists) {
      if ([listID isEqualToString:[list objectForKey:@"id"]]) {
         found = YES;

         STAssertTrue([[list objectForKey:@"archived"] isEqualToString:@"0"], nil);
         break;
      }
   }
   STAssertTrue(found, nil);
}

@end