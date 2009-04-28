//
//  ListTest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPIList.h"
#import "RTMAPI.h"
#import "RTMAuth.h"

@interface RTMAPIListTest : SenTestCase
{
  RTMAuth *auth;
  RTMAPI *api;
}
@end

@implementation RTMAPIListTest

- (void) setUp
{
  auth = [[RTMAuth alloc] init];
  api  = [[RTMAPI alloc] init];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
  [RTMAPI setToken:auth.token];
}

- (void) tearDown
{
  [api release];
  [auth release];
}

- (void) testGetList
{
	RTMAPIList *list_api = [[[RTMAPIList alloc] init] autorelease];
	STAssertTrue([[list_api getList] count] > 0, @"lists should be one or more.");
}

- (void) _testAddDelete
{
	RTMAPIList *list_api = [[[RTMAPIList alloc] init] autorelease];

	NSInteger count_first = [[list_api getList] count];

  // add
  NSString *list_id = [list_api add:@"testAdd" withFilter:nil];
  NSLog(@"new list id = %@", list_id);
	STAssertNotNil(list_id, @"list should be added.");

  // get lists for check added
	NSArray *lists = [list_api getList];
  NSInteger count_added = [lists count];
  STAssertEquals(count_added, count_first+1, @"lists count check");

  // check: is new list in lists ?
  BOOL found = NO;
  NSDictionary *list;
  for (list in lists) {
    if ([list_id isEqualToString:[list objectForKey:@"id"]]) {
      found = YES;
      break;
    }
  }
  STAssertTrue(found, @"list id existent check");

  // delete
  STAssertTrue([list_api delete:list_id], @"delete check");

  // get lists again for check deleted
	lists = [list_api getList];
  NSInteger count_deleted = [lists count];
  STAssertEquals(count_deleted, count_first, @"lists count check");

  // check: does new list no longer exist in lists ?
  found = NO;
  for (list in lists) {
    if ([list_id isEqualToString:[list objectForKey:@"id"]]) {
      found = YES;
      break;
    }
  }
  STAssertFalse(found, @"list id absense check");
}

@end
