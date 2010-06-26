//
//  MPListViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RTMAPI+List.h"
#import "RTMAPI+Task.h"
#import "MPListViewController.h"
#import "MPTaskListViewController.h"
#import "MPHelper.h"
#import "MPLogger.h"

#pragma mark CheckButtonImageView

@interface CheckButtonImageView : UIImageView
{
}

@end


#pragma mark -
#pragma mark CountCircleView

@interface CountCircleView : UIView
{
   NSUInteger count;
   UILabel *countLabel;
}
@property (nonatomic) NSUInteger count;
@end

@implementation CountCircleView
@synthesize count;

- (id) initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor clearColor];
      count = 0;

      countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 3, self.frame.origin.y + 3, self.frame.size.width - 6, self.frame.size.height - 6)];
      countLabel.textColor = [UIColor colorWithRed:0.000 green:0.251 blue:0.502 alpha:1.000];
      countLabel.text = [NSString stringWithFormat:@"%d", count];
      countLabel.textAlignment = UITextAlignmentCenter;
      countLabel.backgroundColor = [UIColor clearColor];
      countLabel.adjustsFontSizeToFitWidth = YES;
      countLabel.minimumFontSize = 8;
      [self addSubview:countLabel];
   }
   return self;
}

- (void) dealloc
{
   [countLabel release];
   [super dealloc];
}

- (void) setCount:(NSUInteger)cnt
{
   count = cnt;
   countLabel.text = [NSString stringWithFormat:@"%d", count];
}

- (void) drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();

   CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:0.20] CGColor]);
   CGContextFillEllipseInRect(context, rect);
}

@end

@implementation MPListViewController

@synthesize fetchedResultsController, managedObjectContext;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];

   self.title = @"Lists";

   // toolbar
   UIBarButtonItem *syncListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(syncList)];
   UIBarButtonItem *syncTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(syncTaskList)];
   UIBarButtonItem *addTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:[UIApplication sharedApplication].delegate action:@selector(showAddTask)];

   self.toolbarItems = [NSArray arrayWithObjects:syncListButton, syncTaskButton, addTaskButton, nil];
   [addTaskButton release];
   [syncListButton release];
   [syncTaskButton release];

   // fetch Lists
   NSError *error = nil;
   if (![[self fetchedResultsController] performFetch:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = [[managedObject valueForKey:@"name"] description];

   if ([[managedObject valueForKey:@"smart"] boolValue]) {
      cell.textLabel.textColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];
      cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
      cell.detailTextLabel.textColor = [UIColor grayColor];
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  ", [managedObject valueForKey:@"filter"]];
   } else {
      cell.textLabel.textColor = [UIColor blackColor];
   }
   
   CountCircleView *ccv = [[CountCircleView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
   NSInteger sum = 0;
   for (NSManagedObject *task in [managedObject valueForKey:@"taskSerieses"]) {
      sum += [[task valueForKey:@"tasks"] count];
   }

   ccv.count = sum;
   cell.accessoryView = ccv;
   [ccv release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
   return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
   
   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   MPTaskListViewController *tlv = [[MPTaskListViewController alloc] initWithStyle:UITableViewStylePlain];
   
   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   tlv.listObject = managedObject;
   tlv.managedObjectContext = self.managedObjectContext;
   [self.navigationController pushViewController:tlv animated:YES];
   [tlv release];
}

#pragma mark -
#pragma mark Memory management

- (void) viewDidUnload
{
   fetchedResultsController.delegate = nil;
}

- (void)dealloc
{
   [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
   if (fetchedResultsController != nil)
      return fetchedResultsController;

   /*
    Set up the fetched results controller.
    */
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];

   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];

   // Edit the sort key as appropriate.
   NSSortDescriptor *positionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
   NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
   NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:positionSortDescriptor, nameSortDescriptor, nil];
   [fetchRequest setSortDescriptors:sortDescriptors];

   NSPredicate *pred = [NSPredicate predicateWithFormat:@"archived == false AND deleted == false"];
   [fetchRequest setPredicate:pred];

   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"ListView"];
   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;

   [aFetchedResultsController release];
   [fetchRequest release];
   [nameSortDescriptor release];
   [positionSortDescriptor release];
   [sortDescriptors release];

   return fetchedResultsController;
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;

      case NSFetchedResultsChangeDelete:
         [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
   UITableView *tableView = self.tableView;

   switch(type) {
      case NSFetchedResultsChangeInsert:
         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;

      case NSFetchedResultsChangeDelete:
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;

      case NSFetchedResultsChangeUpdate:
         [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
         break;

      case NSFetchedResultsChangeMove:
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView endUpdates];
}

#pragma mark -
#pragma mark List API

- (NSNumber *) integerNumberFromString:(NSString *)string
{
   return [NSNumber numberWithInteger:[string integerValue]];
}

- (NSNumber *) boolNumberFromString:(NSString *)string
{
   return [NSNumber numberWithBool:[string boolValue]];
}

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
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [listID integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
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
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [[list objectForKey:@"id"] integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   NSAssert([fetched count] == 1, @"should be 1");
   NSManagedObject *listObject = [fetched objectAtIndex:0];

   BOOL updated = NO;

   if (! [[list objectForKey:@"name"] isEqualToString:[listObject valueForKey:@"name"]]) {
      updated = YES;
      [listObject setValue:[list objectForKey:@"name"] forKey:@"name"];
   }

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
      if (![managedObjectContext save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
}

- (void) syncList
{
   RTMAPI *api = [[RTMAPI alloc] init];
   if (api.token == nil) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"no token" message:@"no token" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [av show];
      [av release];
      [api release];
      return;
   }

   NSArray *listsRetrieved = [api getList];
   NSSet *deletedLists = [self deletedLists:listsRetrieved];
   for (NSManagedObject *deletedList in deletedLists)
      [managedObjectContext deleteObject:deletedList];

   for (NSDictionary *list in listsRetrieved) {
      if ([self isListExist:[list objectForKey:@"id"]]) {
         [self updateIfNeeded:list];
      } else {
         [self insertNewList:list];
      }
   }
      
   [api release];
}

#pragma mark -
#pragma mark Task API

- (void)insertNewTask:(NSDictionary *)taskseries
{
   // make a relationship.
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *listEntity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:listEntity];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"iD == %d", [[taskseries objectForKey:@"list_id"] integerValue]];
   [fetchRequest setPredicate:pred];
   
   NSError *error = nil;
   NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
   if (error) {
      LOG(@"error");
      abort();
   }
   
   NSAssert([fetched count] == 1, @"should be 1");
   NSManagedObject *listObject = [fetched objectAtIndex:0];

   if ([[listObject valueForKey:@"smart"] boolValue]) {
      LOG(@"something bad happens");
      LOG(@"taskseries = %@, list = %@", taskseries, listObject);
      return;
   }
   NSAssert([[listObject valueForKey:@"smart"] boolValue] == NO, @"the task should not belong to any smart lists.");

   NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskSeries" inManagedObjectContext:managedObjectContext];
   NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
   
   // If appropriate, configure the new managed object.
   [newManagedObject setValue:[taskseries objectForKey:@"name"] forKey:@"name"];
   NSNumber *iD = [NSNumber numberWithInteger:[[taskseries objectForKey:@"id"] integerValue]];
   [newManagedObject setValue:iD forKey:@"iD"];
   NSDate *created = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"created"]];
   [newManagedObject setValue:created forKey:@"created"];   
   
   if ([taskseries objectForKey:@"modified"]) {
      NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"modified"]];
      [newManagedObject setValue:date forKey:@"modified"];
   }      
   if ([taskseries objectForKey:@"rrule"]) {
      NSDictionary *rrule = [taskseries objectForKey:@"rrule"];
      NSString *packedRrule = [NSString stringWithFormat:@"%@-%@", [rrule objectForKey:@"every"], [rrule objectForKey:@"rule"]];
      [newManagedObject setValue:packedRrule forKey:@"rrule"];
   }

   [newManagedObject setValue:listObject forKey:@"inList"];

   // setup Tasks in the TaskSeries
   for (NSDictionary *task in [taskseries objectForKey:@"tasks"]) {
      NSEntityDescription *taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
      NSManagedObject *newTask = [NSEntityDescription insertNewObjectForEntityForName:[taskEntity name] inManagedObjectContext:managedObjectContext];
      
      NSNumber *taskID = [NSNumber numberWithInteger:[[task objectForKey:@"id"] integerValue]];
      [newTask setValue:taskID forKey:@"iD"];
      
      if ([task objectForKey:@"added"]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"added"]];
         [newTask setValue:date forKey:@"added"];
      }

      NSString *completedString = [task objectForKey:@"completed"];
      if (completedString && ! [completedString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"completed"]];
         [newTask setValue:date forKey:@"completed"];
      }
      
      NSString *deletedString = [task objectForKey:@"deleted"];
      if (deletedString && ! [deletedString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"deleted"]];
         [newTask setValue:date forKey:@"deleted"];
      }

      NSString *dueString = [task objectForKey:@"due"];
      if (dueString && ! [dueString isEqualToString:@""]) {
         NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"due"]];
         [newTask setValue:date forKey:@"due"];
      }

      NSString *estimateString = [task objectForKey:@"estimate"];
      if (estimateString && ! [estimateString isEqualToString:@""]) {
         [newTask setValue:[task objectForKey:@"estimate"] forKey:@"estimate"];
      }

      [newTask setValue:[self boolNumberFromString:[task objectForKey:@"has_due_time"]] forKey:@"has_due_time"];
      [newTask setValue:[self integerNumberFromString:[task objectForKey:@"postponed"]] forKey:@"postponed"];
      
      NSString *priorityString = [task objectForKey:@"priority"];
      NSInteger priority = [priorityString isEqualToString:@"N"] ? 0 : [priorityString integerValue];
      [newTask setValue:[NSNumber numberWithInteger:priority] forKey:@"priority"];

      [newTask setValue:newManagedObject forKey:@"taskSeries"];
   }
   
   // Save the context.
   error = nil;
   if (![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}


- (void) syncTaskList
{
   RTMAPI *api = [[RTMAPI alloc] init];
   if (api.token == nil) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"no token" message:@"no token" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [av show];
      [av release];
      [api release];
      return;
   }
   
   NSArray *tasksRetrieved = [api getTaskList];

   for (NSDictionary *taskseries in tasksRetrieved) {
      [self insertNewTask:taskseries];
   }
   
   [api release];
}

@end