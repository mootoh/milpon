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
#import "MPTaskMediator.h"
#import "MPListMediator.h"
#import "PrivateInfo.h"
#import "MPLogger.h"

@interface MPTaskMediatorTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;
   
   NSManagedObjectModel         *managedObjectModel;
   NSManagedObjectContext       *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;   
   NSFetchedResultsController   *listFetchedResultsController, *taskFetchedResultsController;
   
   MPListMediator *listMediator;
   MPTaskMediator *taskMediator;
}

@end

@implementation MPTaskMediatorTest

- (void) setUpListMediator
{
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   [fetchRequest setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext]];
   [fetchRequest setFetchBatchSize:20];
   
   NSSortDescriptor *idSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"iD" ascending:YES] autorelease];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"archived == false AND deleted == false"];
   [fetchRequest setPredicate:pred];
   
   listFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"ListMediatorTest"];

   listMediator = [[MPListMediator alloc] initWithFetchedResultsController:listFetchedResultsController];
}
   
- (void) tearDownListMediator
{
   // clean up the entities
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   [fetchRequest setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext]];
   
   NSError *error = nil;
   NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   STAssertNil(error, nil);
   
   for (NSManagedObject *managedObject in items)
      [managedObjectContext deleteObject:managedObject];
   
   if ([items count] > 0) {
      [managedObjectContext save:&error];
      if (error) {
         LOG(@"Failed to save to data store: %@", [error localizedDescription]);
         NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
         if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
               LOG(@"  DetailedError: %@", [detailedError userInfo]);
            }
         }
         else {
            LOG(@"  %@", [error userInfo]);
         }
      }
      STAssertNil(error, [error localizedDescription]);
   }
   
   [listFetchedResultsController release];
   [listMediator release];
}

- (void) setUpTaskMediator
{
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext]];
   [fetchRequest setFetchBatchSize:20];
   
   NSSortDescriptor *idSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"iD" ascending:YES] autorelease];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
   
   taskFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"TaskMediatorTest"];
   
   taskMediator = [[MPTaskMediator alloc] initWithFetchedResultsController:taskFetchedResultsController];
}   

- (void) tearDownTaskMediator
{
   // clean up the entities
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext]];
   
   NSError *error = nil;
   NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   STAssertNil(error, nil);

   for (NSManagedObject *managedObject in items) {
      LOG(@"mo = %@", managedObject);
      [managedObjectContext deleteObject:managedObject];
   }

   if ([items count] > 0) {
      [managedObjectContext save:&error];
      STAssertNil(error, [error localizedDescription]);
   }

   [taskFetchedResultsController release];
   [taskMediator release];
}

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
   
   [self setUpListMediator];
   [self setUpTaskMediator];
}

- (void) tearDown
{
   [self tearDownTaskMediator];
   [self tearDownListMediator];
   [managedObjectContext release];
   [managedObjectModel release];
   [persistentStoreCoordinator release];
   [api release];
}

#pragma mark -

- (void) testSync
{
   [listMediator sync:api];
   [taskMediator sync:api];
   /*

   NSError *error = nil;
   [taskFetchedResultsController performFetch:&error];
   STAssertNil(error, nil);
   NSLog(@"result = %@", [taskFetchedResultsController fetchedObjects]);
   STAssertTrue([[taskFetchedResultsController fetchedObjects] count] > 0, nil);
*/
}

@end