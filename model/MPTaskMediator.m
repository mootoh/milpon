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
#import "RTMAPI+Timeline.h"
#import "MPLogger.h"
#import "MPHelper.h"
#import "MPTask.h"

@implementation MPTaskMediator

#pragma mark -

- (NSArray *) allEntities:(NSString *) entityName predicate:(NSPredicate *) pred
{
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   if (pred)
      [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      [fetchRequest release];
      abort();
   }
   return fetched;
}

- (NSArray *) allTaskSerieses
{
   return [self allEntities:@"TaskSeries" predicate:nil];
}

- (NSArray *) allTasks
{
   return [self allEntities:@"Task" predicate:nil];
}

- (NSArray *) modifiedTaskSerieses
{
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"edit_bits != 0"];
   return [self allEntities:@"TaskSeries" predicate:pred];
}

- (NSArray *) modifiedTasks
{
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"edit_bits != 0"];
   return [self allEntities:@"Task" predicate:pred];
}

- (MPTask *) task:(NSNumber *) task_id
{
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [task_id integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *tasks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }

   if ([tasks count] == 0) return nil;

   NSAssert([tasks count] == 1, nil);
   return [tasks objectAtIndex:0];
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
   return listObject;
}
   
- (void)insertNewTask:(NSDictionary *)taskseries
{
   NSManagedObject *list = [self associatedList:[taskseries objectForKey:@"list_id"]];
   NSAssert(list, nil);
   
   // skip smart list
   if ([[list valueForKey:@"smart"] boolValue]) {
      LOG(@"something bad happens");
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

   if ([taskseries objectForKey:@"url"])
      [newTaskSeries setValue:[taskseries objectForKey:@"url"] forKey:@"url"];

   if ([taskseries objectForKey:@"tags"]) {
      NSMutableSet *tags_to_set = [NSMutableSet set];

      for (NSString *tag in [taskseries objectForKey:@"tags"]) {
         NSManagedObject *tag_to_set = nil;

         // search for existing tag
         NSArray *existing_tags = [self allEntities:@"Tag" predicate:nil];
         for (NSManagedObject *existing_tag in existing_tags) {
            if ([tag isEqualToString:[existing_tag valueForKey:@"name"]]) { // found
               tag_to_set = existing_tag;
               break;
            }
         }
         if (! tag_to_set) {
            NSManagedObject *newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:managedObjectContext];
            [newTag setValue:tag forKey:@"name"];
            tag_to_set = newTag;
         }
         [tags_to_set addObject:tag_to_set];
      }
      if ([tags_to_set count] > 0)
         [newTaskSeries setValue:tags_to_set forKey:@"tags"];
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
         [newTask setValue:date forKey:@"deleted_"];
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
      
      [newTask setValue:boolNumberFromString([task objectForKey:@"has_due_time"]) forKey:@"has_due_time"];
      [newTask setValue:integerNumberFromString([task objectForKey:@"postponed"]) forKey:@"postponed"];
      
      NSString *priorityString = [task objectForKey:@"priority"];
      NSInteger priority = [priorityString isEqualToString:@"N"] ? 0 : [priorityString integerValue];
      [newTask setValue:[NSNumber numberWithInteger:priority] forKey:@"priority"];
      
      [newTask setValue:newTaskSeries forKey:@"taskSeries"];
   }
   
   // Save the context.
   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
      LOG(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (NSSet *) deletedTaskSerieses:(NSArray *) taskSerieses
{
   NSMutableSet *deleted = [NSMutableSet set];
   NSArray *allTaskSerieses = [self allTaskSerieses];
   for (NSManagedObject *taskSeries in allTaskSerieses) {
      NSString *idString = [NSString stringWithFormat:@"%d", [[taskSeries valueForKey:@"iD"] integerValue]];
      NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id == %@)", idString];
      NSArray *exists = [taskSerieses filteredArrayUsingPredicate:pred];
      if ([exists count] == 0)
         [deleted addObject:taskSeries];
   }
   return deleted;
}

- (void) deleteRemotelyDeletedItems:(NSArray *)taskSerieses
{
   BOOL is_deleted = NO;

   for (NSDictionary *taskSeries in taskSerieses) {
      for (NSDictionary *task in [taskSeries objectForKey:@"tasks"]) {
         NSString *deleted = [task objectForKey:@"deleted"];
         if (deleted && ![deleted isEqualToString:@""]) { // deleted
            MPTask *mp_task = [self task:[task objectForKey:@"id"]];
            if (! mp_task) continue;
            
            [managedObjectContext deleteObject:mp_task];
            is_deleted = YES;
         }
      }
   }
   
   if (is_deleted) {
      NSError *error = nil;
      if (![managedObjectContext save:&error]) {
         LOG(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
}

- (void) deleteOrphanTaskSerieses
{
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskSeries" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"tasks.@count == 0"];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *taskSerieses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   for (NSManagedObject *taskSeries in taskSerieses)
      [self.managedObjectContext deleteObject:taskSeries];

   if (![managedObjectContext save:&error]) {
      LOG(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (void) deleteOrphanTasks {}
- (void) deleteOrphanNotes {}
- (void) deleteOrphanTags  {}

- (void) updateIfNeeded:(NSDictionary *) taskSeries
{
   // TODO
}

- (NSArray *) locallyCreatedTaskSerieses
{
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == -1"];
   return [self allEntities:@"TaskSeries" predicate:pred];
}

- (void) deleteTaskSeries:(NSManagedObject *) taskSeries
{
   [managedObjectContext deleteObject:taskSeries];
}

- (void) createAndSyncTask:(RTMAPI *)api
{
   NSString *timelineForAdd = [api createTimeline];
   for (NSManagedObject *taskSeries in [self locallyCreatedTaskSerieses]) {
      NSAssert([[taskSeries valueForKey:@"tasks"] count] == 1, @"locally created taskSeries should have only 1 task.");

      // create at remote
      NSDictionary *addedTaskSeries = [api addTask:[taskSeries valueForKey:@"name"] list_id:[taskSeries valueForKeyPath:@"inList.iD"] timeline:timelineForAdd];
      LOG(@"addedTaskseries = %@", addedTaskSeries);
      
      // sync the attributes
      // - rrule
      // - url
      // - location
      //
      // - notes
      //  - title
      //  - body
      //
      // - participants
      // - tags
      // 
      // - tasks
      //  - completed
      //  - due
      //  - estimate
      //  - has_due_time
      //  - postponed
      //  - priority

      // create at local
      [self insertNewTask:addedTaskSeries];
      
      // replace the local task & taskSeries with retrieved ones.
      [self deleteTaskSeries:taskSeries];
   }

   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
      LOG(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

// TODO: take a transactional approach to make sure the data integrity.
- (void) sync:(RTMAPI *) api
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSDate *lastSync = [defaults valueForKey:@"lastSync"];
   NSArray *taskSeriesesRetrieved = lastSync
      ? [api getTaskList:[[MilponHelper sharedHelper] dateToRtmString:lastSync]]
      : [api getTaskList];

   // check deleted TaskSerieses
   [self deleteRemotelyDeletedItems:taskSeriesesRetrieved];
   [self deleteOrphanTaskSerieses];
   [self deleteOrphanTasks];
   [self deleteOrphanNotes];
   [self deleteOrphanTags];

   [self createAndSyncTask:api];

   // upload local modifications
   for (NSManagedObject *taskSeries in [self modifiedTaskSerieses]) {
      LOG(@"modified taskSeries : %@", taskSeries);
      NSInteger edit_bits = [[taskSeries valueForKey:@"edit_bits"] integerValue];
   }
   
   NSString *timeline = [api createTimeline];

   for (MPTask *task in [self modifiedTasks]) {
      LOG(@"modified task : %@", task);
      NSInteger edit_bits = [[task valueForKey:@"edit_bits"] integerValue];
      if (edit_bits & EDIT_BITS_TASK_COMPLETION) {
         if ([task is_completed]) {
            [api completeTask:[task valueForKey:@"iD"] taskseries_id:[task valueForKeyPath:@"taskSeries.iD"] list_id:[task valueForKeyPath:@"taskSeries.inList.iD"] timeline:timeline];
         } else {
            [api uncompleteTask:[task valueForKey:@"iD"] taskseries_id:[task valueForKeyPath:@"taskSeries.iD"] list_id:[task valueForKeyPath:@"taskSeries.inList.iD"] timeline:timeline];
         }
      }
   }
   
   // create or update Tasks
   for (NSDictionary *taskseries in taskSeriesesRetrieved) {
      BOOL is_deleted = NO;
      for (NSDictionary *task in [taskseries objectForKey:@"tasks"]) {
         NSString *deletedString = [task objectForKey:@"deleted"];
         if (deletedString && ![deletedString isEqualToString:@""]) {
            is_deleted = YES;
            break;
         }
      }
      if (is_deleted) continue;

      // check existance
      //   if exist, modify it.
      //   else, insert as a new task.
      [self insertNewTask:taskseries];
   }
   
   [defaults setValue:[NSDate date] forKey:@"lastSync"];
}

@end