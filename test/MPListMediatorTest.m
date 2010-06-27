//
//  MPListMediatorTest.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI+Timeline.h"
#import "RTMAPI+List.h"
#import "RTMAPI.h"
#import "MPListMediator.h"
#import "PrivateInfo.h"
#import "MPLogger.h"

@interface MPListMediator (Test)

- (NSManagedObject *) isListExist:(NSString *)listID;
- (void)insertNewList:(NSDictionary *)list;
- (NSSet *) deletedLists:(NSArray *) listsRetrieved;

@end

@interface MPListMediatorTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;

   NSManagedObjectModel         *managedObjectModel;
   NSManagedObjectContext       *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;   
   NSFetchedResultsController   *fetchedResultsController;
   
   MPListMediator *listMediator;
}

@end

@implementation MPListMediatorTest

- (void) setUp
{
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;

   /*
    * setup CoreData stack.
    */
   managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]] retain];

   NSURL            *storeUrl = [NSURL fileURLWithPath:@"/tmp/MilponUnitTest.sqlite"];
   persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
   STAssertNotNil([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:nil], nil);

   managedObjectContext = [[NSManagedObjectContext alloc] init];
   [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];

   /*
    * construct FetchedResultsController.
    */
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   [fetchRequest setFetchBatchSize:20];
   
   NSSortDescriptor *positionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
   NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
   NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:positionSortDescriptor, nameSortDescriptor, nil];
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"archived == false AND deleted == false"];
   [fetchRequest setPredicate:pred];
   
   fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"ListMediatorTest"];
   
   [fetchRequest release];
   [nameSortDescriptor release];
   [positionSortDescriptor release];
   [sortDescriptors release];
   
   listMediator = [[MPListMediator alloc] initWithFetchedResultsController:fetchedResultsController];
}

- (void) tearDown
{
   // clean up the entities
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];

   NSError *error = nil;
   NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   STAssertNil(error, nil);
   [fetchRequest release];

   for (NSManagedObject *managedObject in items)
      [managedObjectContext deleteObject:managedObject];

   [managedObjectContext save:&error];
   STAssertNil(error, nil);

   [listMediator release];
   [fetchedResultsController release];
   [managedObjectContext release];
   [managedObjectModel release];
   [persistentStoreCoordinator release];
   [api release];
}

#pragma mark -

- (void) testIsExist
{
   // DB is clean, so any List entities should not be found.
   STAssertNil([listMediator isListExist:@"1"], nil);

   NSArray *listsRetrieved = [api getList];
   NSString *firstListID = [[listsRetrieved objectAtIndex:0] objectForKey:@"id"];
   NSManagedObject *firstList = [listMediator isListExist:firstListID];
   LOG(@"firstList = %@", firstList);
   STAssertNil(firstList, nil);
}

- (void) testSync
{
   [listMediator sync:api];
   NSError *error = nil;
   [fetchedResultsController performFetch:&error];
   STAssertNil(error, nil);
   NSLog(@"result = %@", [fetchedResultsController fetchedObjects]);
   STAssertTrue([[fetchedResultsController fetchedObjects] count] > 0, nil);

   {
      // check the retrieved list is in the local DB.
      NSArray *listsRetrieved = [api getList];
      NSString *firstListID = [[listsRetrieved objectAtIndex:0] objectForKey:@"id"];
      NSManagedObject *firstList = [listMediator isListExist:firstListID];
      LOG(@"firstList = %@", firstList);
      STAssertNotNil(firstList, nil);
   }

   // then, add a list to the remote.
   NSString *listNameToBeAdded = @"listNameToBeAdded";
   timeline = [api createTimeline];
   NSDictionary *addedList = [api add:listNameToBeAdded timeline:timeline filter:nil];
   STAssertNotNil(addedList, nil);
   NSString *addedListID = [addedList objectForKey:@"id"];

   // added list should not be found on local.
   STAssertNil([listMediator isListExist:addedListID], nil);

   // then sync
   [listMediator sync:api];

   { // now it shold be found on the local.
      NSManagedObject *theList = [listMediator isListExist:addedListID];
      LOG(@"firstList = %@", theList);
      STAssertNotNil(theList, nil);
   }

   // delete the added list from the remote.
   STAssertTrue([api delete:addedListID timeline:timeline], nil);

   // sync, and the list also should be deleted from the local.
   [listMediator sync:api];
   { // now it shold be found on the local.
      NSManagedObject *theList = [listMediator isListExist:addedListID];
      STAssertNil(theList, nil);
   }
}

@end