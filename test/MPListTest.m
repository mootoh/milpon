//
//  MPListTest.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI+Timeline.h"
#import "RTMAPI+List.h"
#import "RTMAPI.h"
#import "PrivateInfo.h"
#import "MPLogger.h"
#import <CoreData/CoreData.h>

@interface MPListTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;
   NSDictionary *createdList;

   NSManagedObjectModel         *managedObjectModel;
   NSManagedObjectContext       *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;   
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MPListTest


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{   
   if (managedObjectContext != nil)
      return managedObjectContext;

   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil) {
      managedObjectContext = [[NSManagedObjectContext alloc] init];
      [managedObjectContext setPersistentStoreCoordinator: coordinator];
   }
   return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
   if (managedObjectModel != nil)
      return managedObjectModel;

   managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]];
   return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (persistentStoreCoordinator != nil)
      return persistentStoreCoordinator;
   
   NSURL *storeUrl = [NSURL fileURLWithPath:@"/tmp/Milpon.sqlite"];
   NSError *error = nil;
   persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
   if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       
       Typical reasons for an error here include:
       * The persistent store is not accessible
       * The schema for the persistent store is incompatible with current managed object model
       Check the error message to determine what the actual problem was.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }    
   
   return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Test code from here.

- (void) setUp
{
   api = [[RTMAPI alloc] init];
   api.token = RTM_TOKEN_D;
   createdList = nil;
//   timeline = [api createTimeline];
//   STAssertNotNil(timeline, nil);
}

- (void) tearDown
{
   if (createdList) {
      NSString *listID = [createdList objectForKey:@"id"];
      [api delete:listID timeline:timeline];
      
      // get lists again to check if the list is absolutely deleted.
      NSArray *lists = [api getList];
      BOOL found = NO;
      for (NSDictionary *list in lists) {
         if ([listID isEqualToString:[list objectForKey:@"id"]]) {
            found = YES;
            break;
         }
      }
      STAssertFalse(found, @"list id absense check");
   }
   
   api.token = nil;
   [api release];
}

- (void) testList
{
   NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
   [newList setValue:[NSNumber numberWithInt:1]   forKey:@"iD"];
   [newList setValue:@"a list"                    forKey:@"name"];
   [newList setValue:[NSNumber numberWithBool:NO] forKey:@"deleted"];
   [newList setValue:[NSNumber numberWithBool:NO] forKey:@"locked"];
   [newList setValue:[NSNumber numberWithBool:NO] forKey:@"archived"];
   [newList setValue:[NSNumber numberWithInt:0]   forKey:@"position"];
   [newList setValue:[NSNumber numberWithBool:0]  forKey:@"smart"];
   [newList setValue:[NSNumber numberWithInt:0]   forKey:@"sort_order"];

   // Save the context.
   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

@end