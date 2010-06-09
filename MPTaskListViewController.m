//
//  MPTaskListViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTaskListViewController.h"
#import "RTMAPI+Task.h"
#import "RTMAPI+Timeline.h"
#import "MilponHelper.h"
#import "MPLogger.h"

@implementation MPTaskListViewController
@synthesize fetchedResultsController, managedObjectContext;
@synthesize listObject;

#pragma mark -
#pragma mark Initialization

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];

   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(syncTaskList)];
   self.toolbarItems = [NSArray arrayWithObjects:addButton, nil];
   [addButton release];

   // Uncomment the following line to preserve selection between presentations.
   //self.clearsSelectionOnViewWillAppear = NO;

   // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//   [self performSelectorInBackground:@selector(getTasks) withObject:nil];

   NSError *error = nil;
   if (![[self fetchedResultsController] performFetch:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   
   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
   
   NSDate *created = [managedObject valueForKey:@"created"];
//   NSDate *now = [NSDate date];

   /*
   NSTimeInterval interval = [created timeIntervalSinceReferenceDate:now];
   LOG(@"interval = %d", interval);
   if (interval >= 0 && interval < 60*60*24*7) {
   }
    */

   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"E"];
   NSString *createdString = [dateFormatter stringFromDate:created];
   cell.detailTextLabel.text = createdString;

   // format with current system locale.
   //   if the due date is in 7 days, use the weekday symbols.
   //   if the due date is in this year, do not use year number
   //   otherwise, use ShortStyle format.
#if 0
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterShortStyle];
   NSString *createdString = [dateFormatter stringFromDate:created];
   cell.detailTextLabel.text = createdString;
#endif // 0
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
   return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   static NSString *CellIdentifier = @"TaskListCell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
   }
   
   // Configure the cell...
   [self configureCell:cell atIndexPath:indexPath];
   
   return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark API

#if 0
- (void) getTasks
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   RTMAPI *api = [[RTMAPI alloc] init];
   if (api.token == nil) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"no token" message:@"no token" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [av show];
      [av release];
   } else {
      self.taskserieses = [api getTaskList:list filter:nil lastSync:nil];
      [self.tableView reloadData];
   }
   
   [api release];
   [pool release];
}

- (void) addTask
{
   RTMAPI *api = [[RTMAPI alloc] init];
   if (api.token == nil) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"no token" message:@"no token" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [av show];
      [av release];
   } else {
      NSString *timeline = [api createTimeline];
      [api addTask:@"testNewUI" list_id:list timeline:timeline];
      [api getTaskList:list filter:nil lastSync:nil];
      [self.tableView reloadData];
   }
   
   [api release];
}
#endif

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
   
   if (fetchedResultsController != nil) {
      return fetchedResultsController;
   }
   
   /*
    Set up the fetched results controller.
    */
   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskSeries" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
   NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"inList.iD == %@", [listObject valueForKey:@"iD"]];
   [fetchRequest setPredicate:pred];
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;
   
   [aFetchedResultsController release];
   [fetchRequest release];
   [sortDescriptor release];
   [sortDescriptors release];
   
   return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
   [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
   
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
         [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
   
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


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
   [self.tableView endUpdates];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark -
#pragma mark Add a new object

- (void)insertNewTask:(NSDictionary *)taskseries {
   
   // Create a new instance of the entity managed by the fetched results controller.
   NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
   NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
   NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
   
   // If appropriate, configure the new managed object.
   [newManagedObject setValue:[taskseries objectForKey:@"name"] forKey:@"name"];
   NSNumber *iD = [NSNumber numberWithInteger:[[taskseries objectForKey:@"id"] integerValue]];
   [newManagedObject setValue:iD forKey:@"iD"];
   NSDate *created = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"created"]];
   [newManagedObject setValue:created forKey:@"created"];   
   [newManagedObject setValue:listObject forKey:@"inList"];
   
   if ([taskseries objectForKey:@"modified"]) {
      NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"modified"]];
      [newManagedObject setValue:date forKey:@"modified"];
   }      
   if ([taskseries objectForKey:@"rrule"]) {
      NSDictionary *rrule = [taskseries objectForKey:@"rrule"];
      NSString *packedRrule = [NSString stringWithFormat:@"%@-%@", [rrule objectForKey:@"every"], [rrule objectForKey:@"rule"]];
      [newManagedObject setValue:packedRrule forKey:@"rrule"];
   }      
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error]) {
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
   
   NSString *listString = [NSString stringWithFormat:@"%d", [[listObject valueForKey:@"iD"] integerValue]];
   NSArray *tasksRetrieved = [api getTaskList:listString filter:nil lastSync:nil];
   for (NSDictionary *taskseries in tasksRetrieved) {
      [self insertNewTask:taskseries];
   }
   
   [api release];
}

@end