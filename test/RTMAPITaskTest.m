//
//  RTMAPITaskTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMAPI+Task.h"
#import "PrivateInfo.h"
#import "logger.h"
//#import "LocalCache.h"

@interface RTMAPITaskTest : SenTestCase {
//   LocalCache *db;
   RTMAPI *api;
}
@end

@implementation RTMAPITaskTest

- (void) setUp
{
//   db   = [[LocalCache sharedLocalCache] retain];
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;
}

- (void) tearDown
{
   api.token = nil;
   [api release];
//   [db release];
}

- (void) _testGetList
{
   NSArray *tasks = [api getTaskList];
   STAssertNotNil(tasks, @"task getList should not be nil");		
   STAssertTrue([tasks count] > 0, @"tasks should be one or more.");
   LOG(@"tasks = %@", tasks);
}

- (void) _testGetListForID
{
   NSArray *tasks = [api getTaskList:@"8698547" filter:nil lastSync:nil];
   STAssertTrue([tasks count] > 0, @"tasks in Inbox should be one or more.");
}

- (void) _testGetLastSync
{
   NSString *lastSync = @"2010-06-05T08:27:05Z";
   NSArray *tasks = [api getTaskList:nil filter:nil lastSync:lastSync];
   STAssertTrue([tasks count] > 0, @"tasks from lastSync %@ should be one or more.", lastSync);
}

- (void) testGetWithFilter
{
   NSString *filter = @"isTagged:true";
   NSArray *tasks = [api getTaskList:nil filter:filter lastSync:nil];
   STAssertTrue([tasks count] > 0, @"tasks with tag should be one or more.");
}

#if 0
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
#endif // 0
@end