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
#import "RTMAPI+Timeline.h"
#import "RTMAPI+Location.h"
#import "PrivateInfo.h"
#import "logger.h"
#import "MilponHelper.h"

@interface RTMAPITaskTest : SenTestCase {
   RTMAPI *api;
}
@end

@implementation RTMAPITaskTest

- (void) setUp
{
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;
}

- (void) tearDown
{
   api.token = nil;
   [api release];
}

- (void) _testGetList
{
   NSSet *tasks = [api getTaskList];
   STAssertNotNil(tasks, @"task getList should not be nil");		
   STAssertTrue([tasks count] > 0, @"tasks should be one or more.");
}

- (void) _testGetListForID
{
   NSSet *tasks = [api getTaskList:@"8698547" filter:nil lastSync:nil];
   STAssertTrue([tasks count] > 0, @"tasks in Inbox should be one or more.");
}

- (void) _testGetLastSync
{
   NSString *lastSync = @"2010-06-05T08:27:05Z";
   NSSet       *tasks = [api getTaskList:nil filter:nil lastSync:lastSync];

   STAssertTrue([tasks count] > 0, @"tasks from lastSync %@ should be one or more.", lastSync);
}

- (void) _testGetWithFilter
{
   NSString *filter = @"isTagged:true";
   NSSet     *tasks = [api getTaskList:nil filter:filter lastSync:nil];

   STAssertTrue([tasks count] > 0, @"tasks with tag should be one or more.");
}

- (void) _testAddAndDelete
{
   NSString     *name = @"testAdd";
   NSString *timeline = [api createTimeline];

   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timeline];
   STAssertNotNil(addedTask, @"");

   NSString       *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString *taskseries_id = [addedTask objectForKey:@"id"];
   NSString       *list_id = [addedTask objectForKey:@"list_id"];
   STAssertNotNil(task_id, nil);
   STAssertNotNil(taskseries_id, nil);
   STAssertNotNil(list_id, nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timeline];
}

- (void) _testAddAndSetDueDateThenDelete
{
   NSString *name        = @"testAddAndSetDueDate";
   NSString *timelineAdd = [api createTimeline];

   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);

   NSString    *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineSetDueDate = [api createTimeline];
   NSString            *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString      *taskseries_id = [addedTask objectForKey:@"id"];
   NSString            *list_id = [addedTask objectForKey:@"list_id"];
   NSString                *due = @"2010-07-01T22:13:00Z";
   [api setTaskDueDate:due timeline:timelineSetDueDate list_id:list_id taskseries_id:taskseries_id task_id:task_id has_due_time:NO parse:NO];

   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary *taskseries = [taskserieses anyObject];
   NSString   *dueSpecified = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"due"];
   STAssertTrue([dueSpecified isEqualToString:due], nil);

   NSString *dueHasTime = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"has_due_time"];
   STAssertTrue([dueHasTime isEqualToString:@"0"], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetDueDate];   
}

- (void) _testAddAndLocatoin
{
   NSSet *locations = [api getLocations];
   STAssertTrue([locations count] > 0, nil);

   NSString *name        = @"testAddAndLocation";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString    *addedDateString  = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineSetLocation = [api createTimeline];
   NSString            *task_id  = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString      *taskseries_id  = [addedTask objectForKey:@"id"];
   NSString            *list_id  = [addedTask objectForKey:@"list_id"];
   [api setTaskLocation:[[locations anyObject] objectForKey:@"id"] timeline:timelineSetLocation list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   
   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary *taskseries  = [taskserieses anyObject];
   NSString     *location_id = [taskseries objectForKey:@"location_id"];
   STAssertTrue([location_id isEqualToString:[[locations anyObject] objectForKey:@"id"]], nil);   

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetLocation];   
}

- (void) testAddAndPriority
{
   NSString *name        = @"testAddAndPriority";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString    *addedDateString  = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineSetPriority = [api createTimeline];
   NSString            *task_id  = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString      *taskseries_id  = [addedTask objectForKey:@"id"];
   NSString            *list_id  = [addedTask objectForKey:@"list_id"];
   NSString            *priority = @"1";
   [api setTaskPriority:priority timeline:timelineSetPriority list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   
   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary *taskseries  = [taskserieses anyObject];
   NSString     *pri = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"priority"];
   STAssertTrue([priority isEqualToString:pri], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetPriority];
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