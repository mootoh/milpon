//
//  RTMAPITaskTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPITask.h"
#import "RTMAPI.h"
#import "LocalCache.h"
#import "RTMAuth.h"

@interface RTMAPITaskTest : SenTestCase {
   LocalCache *db;
   RTMAuth *auth;
   RTMAPI *api;
}
@end

@implementation RTMAPITaskTest

- (void) setUp
{
   db   = [[LocalCache sharedLocalCache] retain];
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
   [db release];
}

- (void) testGetList
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSArray *tasks = [api_task getList];
   STAssertNotNil(tasks, @"task getList should not be nil");		
   STAssertTrue([tasks count] > 0, @"tasks should be one or more.");
}

- (void) testGetListForID
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   STAssertTrue([[api_task getListForList:@"977050"] count] > 0, @"tasks in Inbox should be one or more.");
}

- (void) testGetListWithLastSync
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];

   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM_ddTHH:mm:ssZ"];

   NSString *last_sync = [formatter stringFromDate:now];

   NSArray *tasks = [api_task getListWithLastSync:last_sync];
   STAssertNotNil(tasks, @"task getListWithLastSync should not be nil");		
   //STAssertTrue([tasks count] == 0, @"tasks should be zero");
}

- (void) testTags
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSArray *tasks = [api_task getList];
   BOOL tag_found = NO;
   for (NSDictionary *taskseries in tasks) { // iterate in taskseries
      NSArray *tags = [taskseries objectForKey:@"tags"];
      if (tags) {
         tag_found = YES;
         break;
      }
   }
   STAssertTrue(tag_found, @"at least one tag should be found.");
}

- (void) testAdd_and_Delete
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSDictionary *ids = [api_task add:@"task add from API." inList:nil];
   STAssertNotNil([ids valueForKey:@"taskseries_id"], @"check created taskseries id");
   STAssertNotNil([ids valueForKey:@"task_id"], @"check created task id");

   STAssertTrue([api_task delete:[ids valueForKey:@"task_id"] inTaskSeries:[ids valueForKey:@"taskseries_id"] inList:[ids valueForKey:@"list_id"]], @"check delete");
}

- (void) testAddInList_and_Delete
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSDictionary *ids = [api_task add:@"task add from API specifying list." inList:@"4922895"];
   STAssertNotNil([ids valueForKey:@"taskseries_id"], @"check created taskseries id");
   STAssertNotNil([ids valueForKey:@"task_id"], @"check created task id");

   STAssertTrue([api_task delete:[ids valueForKey:@"task_id"] inTaskSeries:[ids valueForKey:@"taskseries_id"] inList:[ids valueForKey:@"list_id"]], @"check delete");
}

@end
