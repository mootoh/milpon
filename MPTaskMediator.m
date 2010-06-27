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

#pragma mark -

- (NSArray *) allEntities:(NSString *) entityName
{
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   return fetched;
}

- (NSArray *) allTaskSerieses
{
   return [self allEntities:@"TaskSeries"];
}

- (NSArray *) allTasks
{
   return [self allEntities:@"Task"];
}

// search for the associated List.
- (NSManagedObject *) associatedList:(NSString *) listID
{
   NSFetchRequest    *fetchRequest = [[NSFetchRequest alloc] init];
   [fetchRequest setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext]];
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [listID integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   NSAssert([fetched count] == 1, @"should be 1");
   NSManagedObject *listObject = [fetched objectAtIndex:0];
   LOG(@"listObject = %@", listObject);
   return listObject;
} 
   
- (void)insertNewTask:(NSDictionary *)taskseries
{
   NSManagedObject *list = [self associatedList:[taskseries objectForKey:@"list_id"]];
   NSAssert(list, nil);
   
   // skip smart list
   if ([[list valueForKey:@"smart"] boolValue]) {
      LOG(@"something bad happens");
//      LOG(@"taskseries = %@, list = %@", taskseries, listObject);
      abort();
      return;
   }
   NSAssert([[list valueForKey:@"smart"] boolValue] == NO, @"the task should not belong to any smart lists.");
   
   /*
    * create TaskSeries entity.
    */
   NSEntityDescription    *entity = [NSEntityDescription entityForName:@"TaskSeries" inManagedObjectContext:managedObjectContext];
   NSManagedObject *newTaskSeries = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
   
   [newTaskSeries setValue:[taskseries objectForKey:@"name"] forKey:@"name"];
   NSNumber *iD = [NSNumber numberWithInteger:[[taskseries objectForKey:@"id"] integerValue]];
   [newTaskSeries setValue:iD forKey:@"iD"];
   NSDate *created = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"created"]];
   [newTaskSeries setValue:created forKey:@"created"];   
   
   if ([taskseries objectForKey:@"modified"]) {
      NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"modified"]];
      [newTaskSeries setValue:date forKey:@"modified"];
   }      
   if ([taskseries objectForKey:@"rrule"]) {
      NSDictionary *rrule = [taskseries objectForKey:@"rrule"];
      NSString *packedRrule = [NSString stringWithFormat:@"%@-%@", [rrule objectForKey:@"every"], [rrule objectForKey:@"rule"]];
      [newTaskSeries setValue:packedRrule forKey:@"rrule"];
   }
   
   [newTaskSeries setValue:list forKey:@"inList"];
   
   // setup Tasks in the TaskSeries
   for (NSDictionary *task in [taskseries objectForKey:@"tasks"]) {
      NSEntityDescription *taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
      NSManagedObject *newTask = [NSEntityDescription insertNewObjectForEntityForName:[taskEntity name] inManagedObjectContext:managedObjectContext];
      
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
      
      [newTask setValue:newTaskSeries forKey:@"taskSeries"];
   }
   
   LOG(@"commiting TaskSeries: %@", newTaskSeries);
   
   // Save the context.
   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
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