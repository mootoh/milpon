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
   NSEntityDescription       *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
   
   // If appropriate, configure the new managed object.
   [newManagedObject setValue:integerNumberFromString([list objectForKey:@"id"]) forKey:@"iD"];
   [newManagedObject setValue:[list objectForKey:@"name"] forKey:@"name"];
   [newManagedObject setValue:boolNumberFromString([list objectForKey:@"deleted"]) forKey:@"deleted_"];
   [newManagedObject setValue:boolNumberFromString([list objectForKey:@"locked"]) forKey:@"locked"];
   [newManagedObject setValue:boolNumberFromString([list objectForKey:@"archived"]) forKey:@"archived"];
   [newManagedObject setValue:integerNumberFromString([list objectForKey:@"position"]) forKey:@"position"];
   BOOL isSmart = [[list objectForKey:@"smart"] boolValue];
   [newManagedObject setValue:[NSNumber numberWithBool:isSmart] forKey:@"smart"];
   [newManagedObject setValue:integerNumberFromString([list objectForKey:@"sort_order"]) forKey:@"sort_order"];
   if (isSmart) {
      NSAssert([list objectForKey:@"filter"], @"smart list should have filter");
      [newManagedObject setValue:[list objectForKey:@"filter"] forKey:@"filter"];
   }
   
   // Save the context.
   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (NSArray *) allLists
{
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   return fetched;
}

- (NSManagedObject *) listByID:(NSString *) listID
{
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [listID integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   if ([lists count] == 0)
      return nil;
   
   NSAssert([lists count] == 1, @"should be 1");
   return [lists objectAtIndex:0];
}
   
- (NSManagedObject *) isListExist:(NSString *)listID
{
   return [self listByID:listID];
}

- (NSSet *) deletedLists:(NSArray *) listsRetrieved
{
   NSMutableSet *deleted = [NSMutableSet set];
   for (NSManagedObject *list in [self allLists]) {
      NSString *idString = [NSString stringWithFormat:@"%d", [[list valueForKey:@"iD"] integerValue]];
      NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id == %@)", idString];
      NSArray *exists = [listsRetrieved filteredArrayUsingPredicate:pred];
      if ([exists count] == 0)
         [deleted addObject:list];
   }
   return deleted;
}

- (void) updateIfNeeded:(NSDictionary *) list
{
   NSManagedObject *theList = [self listByID:[list objectForKey:@"id"]];

   // update it.
   BOOL updated = NO;
   if (! [[list objectForKey:@"name"] isEqualToString:[theList valueForKey:@"name"]]) {
      // name has been changed
      updated = YES;
      [theList setValue:[list objectForKey:@"name"] forKey:@"name"];
   }
   
   // "deleted" attribute would not be set in the getList API call.
#ifdef SUPPORT_LIST_DELETED
   if (! [[list objectForKey:@"deleted"] boolValue] == [[theList valueForKey:@"deleted_"] boolValue]) {
      updated = YES;
      [theList setValue:[self boolNumberFromString:[list objectForKey:@"deleted"]] forKey:@"deleted_"];
   }
#endif // SUPPORT_LIST_DELETED
   
   if (! [[list objectForKey:@"locked"] boolValue] == [[theList valueForKey:@"locked"] boolValue]) {
      updated = YES;
      [theList setValue:boolNumberFromString([list objectForKey:@"locked"]) forKey:@"locked"];
   }
   
   if (! [[list objectForKey:@"archived"] boolValue] == [[theList valueForKey:@"archived"] boolValue]) {
      updated = YES;
      [theList setValue:boolNumberFromString([list objectForKey:@"archived"]) forKey:@"archived"];
   }
   
#ifdef SUPPORT_LIST_POSITION
   if (! [[list objectForKey:@"position"] integerValue] == [[theList valueForKey:@"position"] integerValue]) {
      updated = YES;
      [theList setValue:[self integerNumberFromString:[list objectForKey:@"position"]] forKey:@"position"];
   }
#endif // SUPPORT_LIST_POSITION
   
   // smart list should be always smart list, so the check below would not be needed.
   BOOL isSmart = [[list objectForKey:@"smart"] boolValue];
   NSAssert([[theList valueForKey:@"smart"] boolValue] == isSmart, @"Smart list should not be migrated to normal list.");
   
   if (! [[list objectForKey:@"sort_order"] integerValue] == [[theList valueForKey:@"sort_order"] integerValue]) {
      updated = YES;
      [theList setValue:integerNumberFromString([list objectForKey:@"sort_order"]) forKey:@"sort_order"];
   }
   
   if (isSmart) {
      NSAssert([list objectForKey:@"filter"], @"smart list should have filter");
      
      if (! [[list objectForKey:@"filter"] isEqualToString:[theList valueForKey:@"filter"]]) {
         updated = YES;
         [theList setValue:[list objectForKey:@"filter"] forKey:@"filter"];
      }
   }
   
   if (updated) {
      // Save the context.
      NSError *error = nil;
      if (![managedObjectContext save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
}

- (void) sync:(RTMAPI *) api
{
   NSArray *listsRetrieved = [api getList];
   
   // first, pick up lists deleted at the remote, and delete from the local.
   NSSet *deletedLists = [self deletedLists:listsRetrieved];
   for (NSManagedObject *deletedList in deletedLists)
      [managedObjectContext deleteObject:deletedList];
   if ([deletedLists count] > 0) {
      NSError *error = nil;
      if (![managedObjectContext save:&error]) {
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

#if 0
   // reload and cache them.
   NSError *error = nil;
   [fetchedResultsController performFetch:&error];
   NSAssert(error == nil, nil);
#endif // 0
}

@end