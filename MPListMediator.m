//
//  MPListMediator.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPListMediator.h"
#import <CoreData/CoreData.h>
#import "RTMAPI.h"
#import "RTMAPI+List.h"
#import "MPLogger.h"

@implementation MPListMediator

#pragma mark -
- (void)insertNewList:(NSDictionary *)list
{
   // Create a new instance of the entity managed by the fetched results controller.
   NSManagedObjectContext   *context = [fetchedResultsController managedObjectContext];
   NSEntityDescription       *entity = [[fetchedResultsController fetchRequest] entity];
   NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
   
   // If appropriate, configure the new managed object.
   [newManagedObject setValue:[self integerNumberFromString:[list objectForKey:@"id"]] forKey:@"iD"];
   [newManagedObject setValue:[list objectForKey:@"name"] forKey:@"name"];
   [newManagedObject setValue:[self boolNumberFromString:[list objectForKey:@"deleted"]] forKey:@"deleted"];
   [newManagedObject setValue:[self boolNumberFromString:[list objectForKey:@"locked"]] forKey:@"locked"];
   [newManagedObject setValue:[self boolNumberFromString:[list objectForKey:@"archived"]] forKey:@"archived"];
   [newManagedObject setValue:[self integerNumberFromString:[list objectForKey:@"position"]] forKey:@"position"];
   BOOL isSmart = [[list objectForKey:@"smart"] boolValue];
   [newManagedObject setValue:[NSNumber numberWithBool:isSmart] forKey:@"smart"];
   [newManagedObject setValue:[self integerNumberFromString:[list objectForKey:@"sort_order"]] forKey:@"sort_order"];
   if (isSmart) {
      NSAssert([list objectForKey:@"filter"], @"smart list should have filter");
      [newManagedObject setValue:[list objectForKey:@"filter"] forKey:@"filter"];
   }
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (NSManagedObject *) isListExist:(NSString *)listID
{
   // Create the fetch request for the entity.
   NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:context];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [listID integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   if ([fetched count] == 0)
      return nil;
   
   NSAssert([fetched count] == 1, @"should be 1");
   return [fetched objectAtIndex:0];
}

- (NSSet *) deletedLists:(NSArray *) listsRetrieved
{
   NSMutableSet *deleted = [NSMutableSet set];
   for (NSManagedObject *mo in [fetchedResultsController fetchedObjects]) {
      NSString *idString = [NSString stringWithFormat:@"%d", [[mo valueForKey:@"iD"] integerValue]];
      NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id == %@)", idString];
      NSArray *exists = [listsRetrieved filteredArrayUsingPredicate:pred];
      if ([exists count] == 0)
         [deleted addObject:mo];
   }
   return deleted;
}

- (void) updateIfNeeded:(NSDictionary *) list
{
   // retrieve the entitiy.
   NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:context];
   [fetchRequest setEntity:entity];
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [[list objectForKey:@"id"] integerValue]];
   [fetchRequest setPredicate:pred];
   NSError *error = nil;
   NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   NSAssert([fetched count] == 1, @"should be 1");
   NSManagedObject *listObject = [fetched objectAtIndex:0];
   
   // update it.
   BOOL updated = NO;
   
   if (! [[list objectForKey:@"name"] isEqualToString:[listObject valueForKey:@"name"]]) {
      // name has been changed
      updated = YES;
      [listObject setValue:[list objectForKey:@"name"] forKey:@"name"];
   }
   
   // "deleted" attribute would not be set in the getList API call.
#ifdef SUPPORT_LIST_DELETED
   if (! [[list objectForKey:@"deleted"] boolValue] == [[listObject valueForKey:@"deleted"] boolValue]) {
      updated = YES;
      [listObject setValue:[self boolNumberFromString:[list objectForKey:@"deleted"]] forKey:@"deleted"];
   }
#endif // SUPPORT_LIST_DELETED
   
   if (! [[list objectForKey:@"locked"] boolValue] == [[listObject valueForKey:@"locked"] boolValue]) {
      updated = YES;
      [listObject setValue:[self boolNumberFromString:[list objectForKey:@"locked"]] forKey:@"locked"];
   }
   
   if (! [[list objectForKey:@"archived"] boolValue] == [[listObject valueForKey:@"archived"] boolValue]) {
      updated = YES;
      [listObject setValue:[self boolNumberFromString:[list objectForKey:@"archived"]] forKey:@"archived"];
   }
   
#ifdef SUPPORT_LIST_POSITION
   if (! [[list objectForKey:@"position"] integerValue] == [[listObject valueForKey:@"position"] integerValue]) {
      updated = YES;
      [listObject setValue:[self integerNumberFromString:[list objectForKey:@"position"]] forKey:@"position"];
   }
#endif // SUPPORT_LIST_POSITION
   
   // smart list should be always smart list, so the check below would not be needed.
   BOOL isSmart = [[list objectForKey:@"smart"] boolValue];
   NSAssert([[listObject valueForKey:@"smart"] boolValue] == isSmart, @"Smart list should not be migrated to normal list.");
   
   if (! [[list objectForKey:@"sort_order"] integerValue] == [[listObject valueForKey:@"sort_order"] integerValue]) {
      updated = YES;
      [listObject setValue:[self integerNumberFromString:[list objectForKey:@"sort_order"]] forKey:@"sort_order"];
   }
   
   if (isSmart) {
      NSAssert([list objectForKey:@"filter"], @"smart list should have filter");
      
      if (! [[list objectForKey:@"filter"] isEqualToString:[listObject valueForKey:@"filter"]]) {
         updated = YES;
         [listObject setValue:[list objectForKey:@"filter"] forKey:@"filter"];
      }
   }
   
   if (updated) {
      // Save the context.
      NSError *error = nil;
      if (![context save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
}

- (void) sync:(RTMAPI *) api
{
   NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
   NSArray *listsRetrieved = [api getList];
   
   // first, pick up lists deleted at the remote, and delete from the local.
   NSSet *deletedLists = [self deletedLists:listsRetrieved];
   for (NSManagedObject *deletedList in deletedLists)
      [context deleteObject:deletedList];
   if ([deletedLists count] > 0) {
      NSError *error = nil;
      if (![context save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
   
   // then, update attributes and insert if not exists.
   for (NSDictionary *list in listsRetrieved)
      if ([self isListExist:[list objectForKey:@"id"]])
         [self updateIfNeeded:list];
      else
         [self insertNewList:list];

   // reload and cache them.
   NSError *error = nil;
   [fetchedResultsController performFetch:&error];
   NSAssert(error == nil, nil);
}

@end