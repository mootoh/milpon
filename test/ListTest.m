//
//  ListTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <SenTestingKit/SenTestingKit.h>
#import "RTMList.h"
//#import "ListProvider.h"

@interface CoreDataProvider : NSObject
{
   NSManagedObjectModel *managedObjectModel;
   NSManagedObjectContext *managedObjectContext;
   NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@end

@interface CoreDataProvider (PrivateCoreDataStack)
   @property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
   @property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
   @property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CoreDataProvider

- (id) init
{
   if (self = [super init]) {
      managedObjectModel = nil;
      managedObjectContext = nil;
      persistentStoreCoordinator = nil;
   }
   return self;
}

- (void) dealloc
{
   NSError *error;
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
   
   [managedObjectContext release];
   [managedObjectModel release];
   [persistentStoreCoordinator release];

   [super dealloc];
}

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
   
   NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
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

   NSURL *url = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"DataModel" ofType:@"mom"]];
   managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
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

   NSString *resourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
   NSURL *storeUrl = [NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"unit_test.sqlite"]];
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

@end

#pragma mark ListTest

@interface ListTest : SenTestCase
{
   //ListProvider *lp;
   CoreDataProvider *cdProvider;
}
@end

@implementation ListTest

- (void) setUp
{
   cdProvider = [[CoreDataProvider alloc] init];
   STAssertNotNil(cdProvider, @"");
   STAssertNotNil(cdProvider.managedObjectContext, @"");
}

- (void) tearDown
{
   [cdProvider release];
}

- (void) testCreate
{
   NSManagedObject *obj = [NSEntityDescription
                           insertNewObjectForEntityForName:@"List"
                           inManagedObjectContext:cdProvider.managedObjectContext];
   [obj setValue:@"inbox" forKey:@"name"];
}

#if 0
- (void) setUp
{
   lp = [ListProvider sharedListProvider];
}

- (void) testListsCount
{
   STAssertEquals(lp.lists.count, 5U, @"should have some list elements.");
}

// emulate create an instance from DB
- (void) testCreate
{
   NSArray *keys = [NSArray arrayWithObjects:@"list.id", @"list.name", @"list.filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], @"list One", @"", nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   RTMList *list = [[RTMList alloc] initByAttributes:attrs];
   STAssertNotNil(list, @"list should be created");
   STAssertEquals(list.iD, 0, @"id check");
   STAssertTrue([list.name isEqualTo:@"list One"], @"name check");
   STAssertTrue([list.filter isEqualTo:@""], @"filter check");
}

- (void) testAttribute
{
   NSArray *lists = [lp lists];
   RTMList *lstZero = [lists objectAtIndex:0];
   STAssertEquals(lstZero.iD, 1, @"id check");
   STAssertTrue([lstZero.name isEqualTo:@"Inbox"], @"name check");
   STAssertNil(lstZero.filter, @"filter check");
   STAssertFalse([lstZero isSmart], @"smart list check");

   RTMList *lstLast = [lists objectAtIndex:lists.count-1];
   STAssertEquals(lstLast.iD, 5, @"id check");
   STAssertTrue([lstLast.name isEqualTo:@"2007List"], @"name check");
   STAssertTrue([lstLast.filter isEqualTo:@"(tag:2007)"], @"filter check");
   STAssertTrue([lstLast isSmart], @"smart list check");
}

- (void) testTasksCount
{
   RTMList *lstZero = [[lp lists] objectAtIndex:0];
   STAssertEquals([lstZero taskCount], 2, @"task count check");
}

- (void) testTasks
{
   RTMList *lstZero = [[lp lists] objectAtIndex:0];

   NSArray *tasks = lstZero.tasks;
   STAssertEquals([tasks count], 3U, @"tasks should be 1.");
}

// should executed last
- (void) testZ999Erase
{
   [lp erase];
   STAssertEquals(lp.lists.count, 0U, @"lists should be erased to zero.");
}

// create in database
- (void) testZ998Create
{
   [lp erase];
   int before = lp.lists.count;

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:77], @"lucky seven", @"", nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [lp create:params];

   int after = lp.lists.count;
   STAssertEquals(after, before+1, @"1 element should be added");
}

/*
- (void) testSync
{
   ListProvider *lp = [ListProvider sharedListProvider];
   [lp sync];
}
*/

#endif // 0
@end