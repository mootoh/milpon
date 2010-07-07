//
//  ListTest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMAPI+Note.h"
#import "RTMAPI+Task.h"
#import "RTMAPI+Timeline.h"
#import "PrivateInfo.h"
#import "MPHelper.h"
#import "MPLogger.h"

@interface RTMAPINoteTest : SenTestCase
{
   RTMAPI *api;
}
@end

@implementation RTMAPINoteTest

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

- (void) _testAdd
{
   NSString    *taskName = @"testNoteAdd";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:taskName list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString   *addedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString   *timelineAddNote = [api createTimeline];
   NSString           *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString     *taskseries_id = [addedTask objectForKey:@"id"];
   NSString           *list_id = [addedTask objectForKey:@"list_id"];

   NSString *note_title = @"note title";
   NSString  *note_text = @"note text";
   
   NSDictionary *note = [api addNote:note_title text:note_text timeline:timelineAddNote list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   STAssertTrue([[note objectForKey:@"title"] isEqualToString:note_title], nil);
   STAssertTrue([[note objectForKey:@"text"]  isEqualToString:note_text], nil);

   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:addedDateString];
   STAssertEquals([taskserieses count], 1U, nil);
   
   NSDictionary  *taskseries = [taskserieses anyObject];
   NSArray            *notes = [taskseries objectForKey:@"notes"];
   STAssertEquals([notes count], 1U, nil);
   NSDictionary *note0 = [notes objectAtIndex:0];
   STAssertTrue([[note0 objectForKey:@"title"] isEqualToString:note_title], nil);
   
   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineAddNote];
}

- (void) _testDelete
{
   NSString    *taskName = @"testNoteAdd";
   NSString *timelineAdd = [api createTimeline];
   
   NSDictionary *addedTask = [api addTask:taskName list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);
   
   NSString   *timelineAddNote = [api createTimeline];
   NSString           *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString     *taskseries_id = [addedTask objectForKey:@"id"];
   NSString           *list_id = [addedTask objectForKey:@"list_id"];
   
   NSString *note_title = @"note title";
   NSString  *note_text = @"note text";
   
   NSDictionary *note = [api addNote:note_title text:note_text timeline:timelineAddNote list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   STAssertTrue([[note objectForKey:@"title"] isEqualToString:note_title], nil);
   STAssertTrue([[note objectForKey:@"text"]  isEqualToString:note_text], nil);
   
   NSString   *deletedDateString = [[MilponHelper sharedHelper] dateToRtmString:[NSDate date]];
   NSString *timelineDeleteNote = [api createTimeline];
   [api deleteNote:[note objectForKey:@"id"] timeline:timelineDeleteNote];
   
   NSSet *taskserieses = [api getTaskList:nil filter:nil lastSync:deletedDateString];
   STAssertEquals([taskserieses count], 1U, nil);
   
   NSDictionary  *taskseries = [taskserieses anyObject];
   NSArray            *notes = [taskseries objectForKey:@"notes"];
   STAssertEquals([notes count], 0U, nil);
   
   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineAddNote];
}

- (void) testEdit
{
   NSString    *taskName = @"testNoteEdit";
   NSString *timelineAdd = [api createTimeline];

   NSDictionary *addedTask = [api addTask:taskName list_id:nil timeline:timelineAdd];
   STAssertNotNil(addedTask, nil);

   NSString   *timelineAddNote = [api createTimeline];
   NSString           *task_id = [[addedTask objectForKey:@"task"] objectForKey:@"id"];
   NSString     *taskseries_id = [addedTask objectForKey:@"id"];
   NSString           *list_id = [addedTask objectForKey:@"list_id"];

   NSString *note_title = @"note title";
   NSString  *note_text = @"note text";
   NSDictionary *note = [api addNote:note_title text:note_text timeline:timelineAddNote list_id:list_id taskseries_id:taskseries_id task_id:task_id];
   STAssertTrue([[note objectForKey:@"title"] isEqualToString:note_title], nil);
   STAssertTrue([[note objectForKey:@"text"]  isEqualToString:note_text], nil);

   NSString *note_title_edited = @"edited title";
   NSString *note_text_edited  = @"edited text";
   NSDictionary *edited_note = [api editNote:[note objectForKey:@"id"] title:note_title_edited text:note_text_edited timeline:timelineAddNote];
   STAssertTrue([[edited_note objectForKey:@"title"] isEqualToString:note_title_edited], nil);
   STAssertTrue([[edited_note objectForKey:@"text"]  isEqualToString:note_text_edited], nil);

   [api deleteTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timelineAddNote];
}

@end