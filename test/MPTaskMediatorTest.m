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

@interface MPTaskMediator (Test)
- (NSArray *) allTaskSerieses;
- (NSArray *) allTasks;
@end

@interface MPTaskMediatorTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;

   NSManagedObjectModel         *managedObjectModel;
   NSManagedObjectContext       *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;   

   MPListMediator *listMediator;
   MPTaskMediator *taskMediator;
}

@end

@implementation MPTaskMediatorTest

#pragma mark -
#pragma mark setup, cleanup
- (void) setupCoreDataStack
{
   managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]] retain];
   
   NSURL            *storeUrl = [NSURL fileURLWithPath:@"/tmp/MilponUnitTest.sqlite"];
   persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
   STAssertNotNil([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:nil], nil);
   
   managedObjectContext = [[NSManagedObjectContext alloc] init];
   [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
}

// clean up the List entities
- (void) deleteEntities:(NSString *) entityName
{
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
   
   NSError *error = nil;
   NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   STAssertNil(error, nil);
   
   for (NSManagedObject *managedObject in items)
      [managedObjectContext deleteObject:managedObject];
   
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

- (void) setUp
{
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;

   [self setupCoreDataStack];   
   listMediator = [[MPListMediator alloc] initWithManagedObjectContext:managedObjectContext];
   taskMediator = [[MPTaskMediator alloc] initWithManagedObjectContext:managedObjectContext];
}

- (void) tearDown
{
   [self deleteEntities:@"TaskSeries"];
   [self deleteEntities:@"Task"];
   [self deleteEntities:@"List"];

   [listMediator release];
   [taskMediator release];

   [managedObjectContext release];
   [persistentStoreCoordinator release];
   [managedObjectModel release];
   [api release];
}

#pragma mark -

- (void) testSync
{
   [listMediator sync:api];
   [taskMediator sync:api];

   NSArray *taskSerieses = [taskMediator allTaskSerieses];
   NSArray *tasks        = [taskMediator allTasks];

   STAssertTrue([taskSerieses count] > 0, nil);
   STAssertTrue([tasks count] > 0, nil);
}

@end