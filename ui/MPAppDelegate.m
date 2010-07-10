//
//  MPAppDelegate.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPListViewController.h"
#import "MPAddTaskViewController.h"
#import "MPLogger.h"

@interface MPAppDelegate (PrivateCoreDataStack)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
@end

@implementation MPAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // Override point for customization after app launch    

   // if not authorized
   //   get token

   MPListViewController *lvc = (MPListViewController *)[navigationController topViewController];
   lvc.managedObjectContext = self.managedObjectContext;

   [window addSubview:[navigationController view]];
   [window makeKeyAndVisible];
   return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
   
   NSError *error = nil;
   if (managedObjectContext != nil) {
      if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
         /*
          Replace this implementation with code to handle the error appropriately.
          
          abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
          */
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      } 
   }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
   if (managedObjectContext != nil) {
      return managedObjectContext;
   }

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
   if (managedObjectModel != nil) {
      return managedObjectModel;
   }
   managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
   return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (persistentStoreCoordinator != nil) {
      return persistentStoreCoordinator;
   }

   NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Milpon.sqlite"]];

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
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
   return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
   [managedObjectContext release];
   [managedObjectModel release];
   [persistentStoreCoordinator release];

   [navigationController release];
   [window release];
   [super dealloc];
}

#pragma mark -

- (void) showAddTask
{
//   MPAddTaskViewController *addTaskViewController = [[MPAddTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];
   MPAddTaskViewController *addTaskViewController = [[MPAddTaskViewController alloc] initWithNibName:@"MPAddTaskView" bundle:nil];
   UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:addTaskViewController];
   [navigationController presentModalViewController:nc animated:YES];
   [addTaskViewController release];
   [nc release];
}

@end