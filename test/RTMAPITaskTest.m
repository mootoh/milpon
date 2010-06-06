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
#import "MPLogger.h"
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

- (void) _testAddAndPriority
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
   NSString             *pri = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"priority"];
   STAssertTrue([priority isEqualToString:pri], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetPriority];
}

- (void) _testAddAndEstimate
{
   NSString *name        = @"testAddAndEstimate";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString     *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineSetEstimate = [api createTimeline];
   NSString             *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString       *taskseries_id = [addedTask objectForKey:@"id"];
   NSString             *list_id = [addedTask objectForKey:@"list_id"];
   NSString            *estimate = @"1 hours";
   [api setTaskEstimate:estimate timeline:timelineSetEstimate list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   
   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);
   
   NSDictionary *taskseries  = [taskserieses anyObject];
   NSString             *est = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"estimate"];
   STAssertTrue([estimate isEqualToString:est], nil);
   
   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetEstimate];
}

- (void) _testAddAndComplete
{
   NSString *name        = @"testAddAndComplete";
   NSString *timelineAdd = [api createTimeline];

   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);

   NSString  *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineComplete = [api createTimeline];
   NSString          *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString    *taskseries_id = [addedTask objectForKey:@"id"];
   NSString          *list_id = [addedTask objectForKey:@"list_id"];
   [api completeTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineComplete];

   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary *taskseries = [taskserieses anyObject];
   NSString      *completed = [[[taskseries objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"completed"];
   STAssertTrue(completed && ![completed isEqualToString:@""], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineComplete];
}

- (void) _testAddAndSetTags
{
   NSString        *name = @"testAddAndSetTags";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString  *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString  *timelineSetTags = [api createTimeline];
   NSString          *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString    *taskseries_id = [addedTask objectForKey:@"id"];
   NSString          *list_id = [addedTask objectForKey:@"list_id"];

   NSSet         *tags = [NSSet setWithObjects:@"fuga", @"hoge", @"moge", nil];
   NSString *tagString = @"";
   for (NSString *tag in tags)
      tagString = [tagString stringByAppendingFormat:@",%@", tag];
   [api setTaskTags:tagString task_id:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetTags];

   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary *taskseries = [taskserieses anyObject];
   NSSet      *tagsAssigned = [taskseries objectForKey:@"tags"];
   STAssertTrue([tags isEqualToSet:tagsAssigned], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetTags];
}

- (void) _testAddAndMoveTo
{
   NSString        *name = @"testAddAndMoveTo";
   NSString *timelineAdd = [api createTimeline];

   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);

   NSString  *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString   *timelineMoveTo = [api createTimeline];
   NSString          *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString    *taskseries_id = [addedTask objectForKey:@"id"];
   NSString     *from_list_id = [addedTask objectForKey:@"list_id"];
   NSString       *to_list_id = @"8698547"; // somewhere
   [api moveTaskTo:to_list_id from_list_id:from_list_id task_id:task_id taskseries_id:taskseries_id timeline:timelineMoveTo];

   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);

   NSDictionary  *taskseries = [taskserieses anyObject];
   NSString   *moved_list_id = [taskseries objectForKey:@"list_id"];
   STAssertTrue([moved_list_id isEqualToString:to_list_id], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:moved_list_id timeline:timelineMoveTo];
}

- (void) testAddAndSetName
{
   NSString        *name = @"testAddAndSetName";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:name list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString  *addedDateString  = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString   *timelineSetName = [api createTimeline];
   NSString          *task_id  = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString    *taskseries_id  = [addedTask objectForKey:@"id"];
   NSString          *list_id  = [addedTask objectForKey:@"list_id"];
   NSString           *nameTo  = @"testAddAndSetNameRenamed";
   [api setTaskName:nameTo timeline:timelineSetName list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   
   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);
   
   NSDictionary  *taskseries = [taskserieses anyObject];
   NSString     *renamedName = [taskseries objectForKey:@"name"];
   STAssertTrue([renamedName isEqualToString:nameTo], nil);
   
   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineSetName];
}


#if 0
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