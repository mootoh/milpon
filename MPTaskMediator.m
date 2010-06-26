//
//  MPTaskMediator.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTaskMediator.h"
#import "RTMAPI.h"
#import "RTMAPI+Task.h"
#import "MPLogger.h"
#import "MPHelper.h"

@implementation MPTaskMediator

- (id) initWithFetchedResultsController:(NSFetchedResultsController *) frc
{
   if (self = [super init]) {
      fetchedResultsController = [frc retain];
   }
   return self;
}

- (void) dealloc
{
   [fetchedResultsController release];
   [super dealloc];
}

#pragma mark -

- (void)insertNewTask:(NSDictionary *)taskseries
{
   NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
   // make a relationship.
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *listEntity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:context];
   [fetchRequest setEntity:listEntity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [[taskseries objectForKey:@"list_id"] integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   NSAssert([fetched count] == 1, @"should be 1");
   NSManagedObject *listObject = [fetched objectAtIndex:0];
   
   // skip smart list
   if ([[listObject valueForKey:@"smart"] boolValue]) {
      LOG(@"something bad happens");
      LOG(@"taskseries = %@, list = %@", taskseries, listObject);
      return;
   }
   NSAssert([[listObject valueForKey:@"smart"] boolValue] == NO, @"the task should not belong to any smart lists.");
   
   // create TaskSeries entity.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskSeries" inManagedObjectContext:context];
   NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
   
   [newManagedObject setValue:[taskseries objectForKey:@"name"] forKey:@"name"];
   NSNumber *iD = [NSNumber numberWithInteger:[[taskseries objectForKey:@"id"] integerValue]];
   [newManagedObject setValue:iD forKey:@"iD"];
   NSDate *created = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"created"]];
   [newManagedObject setValue:created forKey:@"created"];   
   
   if ([taskseries objectForKey:@"modified"]) {
      NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"modified"]];
      [newManagedObject setValue:date forKey:@"modified"];
   }      
   if ([taskseries objectForKey:@"rrule"]) {
      NSDictionary *rrule = [taskseries objectForKey:@"rrule"];
      NSString *packedRrule = [NSString stringWithFormat:@"%@-%@", [rrule objectForKey:@"every"], [rrule objectForKey:@"rule"]];
      [newManagedObject setValue:packedRrule forKey:@"rrule"];
   }
   
   [newManagedObject setValue:listObject forKey:@"inList"];
   
   // setup Tasks in the TaskSeries
   for (NSDictionary *task in [taskseries objectForKey:@"tasks"]) {
      NSEntityDescription *taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
      NSManagedObject *newTask = [NSEntityDescription insertNewObjectForEntityForName:[taskEntity name] inManagedObjectContext:context];
      
      NSNumber *taskID = [NSNumber numberWithInteger:[[task objectForKey:@"id"] integerValue]];
      [newTask setValue:taskID forKey:@"iD"];
      
      if ([task objectForKey:@"added"]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"added"]];
         [newTask setValue:date forKey:@"added"];
      }
      
      NSString *completedString = [task objectForKey:@"completed"];
      if (completedString && ! [completedString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"completed"]];
         [newTask setValue:date forKey:@"completed"];
      }
      
      NSString *deletedString = [task objectForKey:@"deleted"];
      if (deletedString && ! [deletedString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"deleted"]];
         [newTask setValue:date forKey:@"deleted"];
      }
      
      NSString *dueString = [task objectForKey:@"due"];
      if (dueString && ! [dueString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"due"]];
         [newTask setValue:date forKey:@"due"];
      }
      
      NSString *estimateString = [task objectForKey:@"estimate"];
      if (estimateString && ! [estimateString isEqualToString:@""]) {
         [newTask setValue:[task objectForKey:@"estimate"] forKey:@"estimate"];
      }
      
      [newTask setValue:[self boolNumberFromString:[task objectForKey:@"has_due_time"]] forKey:@"has_due_time"];
      [newTask setValue:[self integerNumberFromString:[task objectForKey:@"postponed"]] forKey:@"postponed"];
      
      NSString *priorityString = [task objectForKey:@"priority"];
      NSInteger priority = [priorityString isEqualToString:@"N"] ? 0 : [priorityString integerValue];
      [newTask setValue:[NSNumber numberWithInteger:priority] forKey:@"priority"];
      
      [newTask setValue:newManagedObject forKey:@"taskSeries"];
   }
   
   // Save the context.
   error = nil;
   if (![context save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (void) sync:(RTMAPI *) api
{
   NSArray *tasksRetrieved = [api getTaskList];
   for (NSDictionary *taskseries in tasksRetrieved) {
      [self insertNewTask:taskseries];
   }
}

@end