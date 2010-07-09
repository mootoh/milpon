//
//  MPTaskTest.m
//  Milpon
//
//  Created by Motohiro Takayama on 7/9/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI+Timeline.h"
#import "RTMAPI+Task.h"
#import "RTMAPI.h"
#import "PrivateInfo.h"
#import "MPLogger.h"
#import "MPTask.h"
#import <CoreData/CoreData.h>

@interface MPTaskTest : SenTestCase
{
   RTMAPI       *api;
   NSString     *timeline;
   
   NSManagedObjectModel         *managedObjectModel;
   NSManagedObjectContext       *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;   
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MPTaskTest

#pragma mark -
#pragma mark Core Data stack

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

- (NSManagedObjectModel *)managedObjectModel
{
   if (managedObjectModel != nil)
      return managedObjectModel;
   
   managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]];
   return managedObjectModel;
}

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
}

- (void) tearDown
{   
   api.token = nil;
   [api release];
}

- (MPTask *) createTask
{
   // List
   NSManagedObject *list = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
   [list setValue:@"a list"                    forKey:@"name"];
   [list setValue:[NSNumber numberWithBool:NO]  forKey:@"smart"];
   
   // TaskSeries
   NSManagedObject *taskSeries = [NSEntityDescription insertNewObjectForEntityForName:@"TaskSeries" inManagedObjectContext:[self managedObjectContext]];
   [taskSeries setValue:list forKey:@"inList"];
   [taskSeries setValue:@"a taskSeries" forKey:@"name"];
   
   // Task
   MPTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[self managedObjectContext]];
   [task setValue:[NSNumber numberWithInt:1] forKey:@"iD"];
   [task setValue:[NSDate date] forKey:@"added"];
   [task setValue:taskSeries forKey:@"taskSeries"];
   
   // Save the context.
   NSError *error = nil;
   if (![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }

   return task;
}

- (void) testCreation
{
   NSManagedObject *task = [self createTask];
   STAssertNotNil(task, nil);
}

- (void) testComplete
{
   MPTask *task = [self createTask];
   NSInteger edit_bits = 0;

   edit_bits = [[task valueForKey:@"edit_bits"] integerValue];
   STAssertFalse(edit_bits & EDIT_BITS_TASK_COMPLETION, nil);
   STAssertNil([task valueForKey:@"completed"], nil);

   [task complete];

   edit_bits = [[task valueForKey:@"edit_bits"] integerValue];
   STAssertTrue(edit_bits & EDIT_BITS_TASK_COMPLETION, nil);
   STAssertNotNil([task valueForKey:@"completed"], nil);
}

@end