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
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"ListMediatorTest"];
//   fetchedResultsController.delegate = self;
   
   [fetchRequest release];
   [nameSortDescriptor release];
   [positionSortDescriptor release];
   [sortDescriptors release];
   
   listMediator = [[MPListMediator alloc] initWithFetchedResultsController:fetchedResultsController];
}

- (void) tearDown
{
   [listMediator release];
   [fetchedResultsController release];
   [managedObjectContext release];
   [managedObjectModel release];
   [persistentStoreCoordinator release];
   [api release];
}

- (void) testSync
{
   [listMediator sync:api];
   NSError *error = nil;
   [fetchedResultsController performFetch:&error];
   STAssertNil(error, nil);
   NSLog(@"result = %@", [fetchedResultsController fetchedObjects]);
   STAssertTrue([[fetchedResultsController fetchedObjects] count] > 0, nil);
}

@end