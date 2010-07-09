//
//  MPTaskListViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTaskListViewController.h"
#import "MPTaskViewController.h"
#import "RTMAPI+Task.h"
#import "RTMAPI+Timeline.h"
#import "MPHelper.h"
#import "MPLogger.h"
#import "MPTask.h"

#pragma mark -
@interface MPTaskCell : UITableViewCell
{
   enum {
      TAG_COMPLETE_BUTTON = 1
   };

   MPTask *task;
}

@property (nonatomic, retain) MPTask *task;

@end

@implementation MPTaskCell
@synthesize task;

static UIColor *s_colors[4] = {nil, nil, nil, nil};

- (UIColor *) priorityColor:(NSInteger) priority
{
   NSAssert(priority >= 0 && priority < 4, @"");

   if (s_colors[0] == nil) {
      s_colors[0] = [[UIColor whiteColor] retain]; // no priority
      s_colors[1] = [[UIColor colorWithRed:0.917 green:0.321 blue:0.0   alpha:1.0] retain]; // orange
      s_colors[2] = [[UIColor colorWithRed:0.0   green:0.376 blue:0.749 alpha:1.0] retain]; // deep blue
      s_colors[3] = [[UIColor colorWithRed:0.207 green:0.604 blue:1.0   alpha:1.0] retain]; // light blue
   }
   
   return s_colors[priority];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
      UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
      checkButton.tag = TAG_COMPLETE_BUTTON;
      [self addSubview:checkButton];
   }
   return self;
}

- (void) drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();

   CGRect nameRect = CGRectMake(44, 8, rect.size.width - 44 - 44, rect.size.height - 20);
   NSString *name = [[[task valueForKey:@"taskSeries"] valueForKey:@"name"] description];

   CGContextSetTextDrawingMode(context, kCGTextFill);

   if ([task valueForKey:@"completed"]) {
      CGContextSetRGBFillColor(context, 0.4, 0.4, 0.4, 1.0);
   } else {
      CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
   }
   
   [name drawInRect:nameRect withFont:[UIFont boldSystemFontOfSize:16]];

   UIButton *checkButton = (UIButton *)[self viewWithTag:TAG_COMPLETE_BUTTON];
   [checkButton setImage:[UIImage imageNamed:[task valueForKey:@"completed"] ? @"checkBoxChecked.png" : @"checkBox.png"] forState:UIControlStateNormal];
   [checkButton addTarget:self action:@selector(toggleCheck) forControlEvents:UIControlEventTouchDown];
   checkButton.frame = CGRectMake(8, 6, 32, 32);
   checkButton.center = CGPointMake(24, rect.size.height/2);

   // draw priority bar
   CGContextSetStrokeColorWithColor(context, [[self priorityColor:[[task valueForKey:@"priority"] integerValue]] CGColor]);
   CGContextSetLineWidth(context, 6.0);
   CGContextMoveToPoint(context, 3.5, 0);
   CGContextAddLineToPoint(context, 3.5, rect.size.height);
   CGContextStrokePath(context);

   // due
   NSDate *due = [task valueForKey:@"due"];
   if (due) {
      NSDate *now = [NSDate date];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      NSTimeInterval interval = [due timeIntervalSinceDate:now];
      LOG(@"interval = %f", interval);
      
      if (interval >= 0 && interval < 60*60*24*7) {
         [dateFormatter setDateFormat:@"E"];
      } else {
         [dateFormatter setDateStyle:NSDateFormatterShortStyle];
      }

      NSString *dueString = [dateFormatter stringFromDate:due];
      CGFloat h = [dueString sizeWithFont:[UIFont boldSystemFontOfSize:11] constrainedToSize:CGSizeMake(80, 1000) lineBreakMode:UILineBreakModeClip].height;
      CGContextSetRGBFillColor(context, 0.4, 0.4, 0.4, 1.0);
      [dueString drawInRect:CGRectMake(48, rect.size.height-h-2, 80, h+2) withFont:[UIFont systemFontOfSize:11]];
   }
}

- (void)prepareForReuse
{
   [task release];
   task = nil;
}

- (void) toggleCheck
{
   if ([task valueForKey:@"completed"]) {
      [task uncomplete];
   } else {
      [task complete];
   }
//   [self setNeedsDisplay];
}

@end

#pragma mark -
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

   showToggle = NO;

   // set up the view
   self.title = [listObject valueForKey:@"name"];

   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(syncTaskList)];

   UISwitch *viewToggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
   [viewToggleSwitch addTarget:self action:@selector(toggleValueChanged:) forControlEvents:UIControlEventValueChanged];
   UIBarButtonItem *toggleItem = [[UIBarButtonItem alloc] initWithCustomView:viewToggleSwitch];
   
   self.toolbarItems = [NSArray arrayWithObjects:addButton, toggleItem, nil];
   [addButton release];
   [toggleItem release];
   [viewToggleSwitch release];

   // [self performSelectorInBackground:@selector(getTasks) withObject:nil];

   // load the contents
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

- (void)configureCell:(MPTaskCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   MPTask *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   cell.task = managedObject;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   NSInteger c = [[fetchedResultsController sections] count];
   return c;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   NSArray *secs = [fetchedResultsController sections];
   id <NSFetchedResultsSectionInfo> sec = [secs objectAtIndex:section];
   return sec.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
   return [sectionInfo numberOfObjects];
}

CGFloat max(CGFloat a, CGFloat b)
{
   return (a > b) ? a : b;
}

static const CGFloat k_DEFAULT_CELL_HEIGHT = 44.0f;

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   if (! managedObject) return k_DEFAULT_CELL_HEIGHT;
   NSString *name = [[[managedObject valueForKey:@"taskSeries"] valueForKey:@"name"] description];
   LOG(@"name = %@", name);
   CGFloat h = [name sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(140, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
   return max(h, k_DEFAULT_CELL_HEIGHT);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   static NSString *CellIdentifier = @"TaskListCell";
   
   MPTaskCell *cell = (MPTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[MPTaskCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
   }
                
   // Configure the cell...
   [self configureCell:cell atIndexPath:indexPath];
   
   return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   MPTaskViewController *tv = [[MPTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];

   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   tv.taskObject = managedObject;
   tv.managedObjectContext = self.managedObjectContext;
   [self.navigationController pushViewController:tv animated:YES];
   [tv release];
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


- (void)dealloc
{
   [fetchedResultsController release];
   [managedObjectContext release];
   [listObject release];
   
   [super dealloc];
}


#pragma mark -
#pragma mark API

#if 0
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

- (NSString *) parseFilter:(NSString *) filter
{
   NSString *ret = @"";

   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];
   
   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
   
   NSDate *todayBegin = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT", [comps year], [comps month], [comps day]]];
   NSDate *todayEnd   = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_23:59:59 GMT", [comps year], [comps month], [comps day]]];
   
   
   ret = [ret stringByAppendingFormat:@"AND due BETWEEN %@", [NSArray arrayWithObjects:todayBegin, todayEnd, nil]];

   return ret;
}

- (NSPredicate *) todayPredicate
{
   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];
   
   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
   
   NSDate *todayBegin = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT", [comps year], [comps month], [comps day]]];
   NSDate *todayEnd   = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_23:59:59 GMT", [comps year], [comps month], [comps day]]];   

   NSPredicate *pred = [NSPredicate predicateWithFormat:@"due >= %@ AND due <= %@", todayBegin, todayEnd];
   return pred;
}

#define k_CACHE_NAME_FOR_COMPLETED     @"taskCompleted"
#define k_CACHE_NAME_FOR_NOT_COMPLETED @"taskNotCompleted"

- (NSFetchedResultsController *) fetchedResultsController
{
   if (fetchedResultsController != nil)
      return fetchedResultsController;
   [NSFetchedResultsController deleteCacheWithName:@"TaskCache"];

   // Create the fetch request for the entity.
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
   [fetchRequest setEntity:entity];

   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];

   // Edit the sort key as appropriate.
   NSSortDescriptor *dueSortDescriptor       = [[NSSortDescriptor alloc] initWithKey:@"due" ascending:YES];
   NSSortDescriptor *completedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
   NSSortDescriptor *nameSortDescriptor      = [[NSSortDescriptor alloc] initWithKey:@"taskSeries.name" ascending:YES];
   NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:completedSortDescriptor, dueSortDescriptor, nameSortDescriptor, nil];
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   NSString *predicateString = [NSString stringWithFormat:@"taskSeries.inList.iD == %@ AND deleted == NULL ", [listObject valueForKey:@"iD"]];
/*   
   if (! showToggle) {
      predicateString = [predicateString stringByAppendingFormat:@"AND completed == NULL"];
   }
 */
   NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
   [fetchRequest setPredicate:pred];
   
//   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"is_completed" cacheName:showToggle ? k_CACHE_NAME_FOR_COMPLETED : k_CACHE_NAME_FOR_NOT_COMPLETED];
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"TaskCache"];

   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;

   [aFetchedResultsController release];
   [fetchRequest release];
   [dueSortDescriptor release];
   [nameSortDescriptor release];
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
         [self configureCell:(MPTaskCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

- (NSNumber *) integerNumberFromString:(NSString *)string
{
   return [NSNumber numberWithInteger:[string integerValue]];
}

- (NSNumber *) boolNumberFromString:(NSString *)string
{
   return [NSNumber numberWithBool:[string boolValue]];
}

- (void)insertNewTask:(NSDictionary *)taskseries {
   
   // Create a new instance of the entity managed by the fetched results controller.
   NSManagedObject *newTaskSeries = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"TaskSeries"
                                   inManagedObjectContext:managedObjectContext];
   
   // setup TaskSeries
   [newTaskSeries setValue:[taskseries objectForKey:@"name"] forKey:@"name"];
   NSNumber *iD = [NSNumber numberWithInteger:[[taskseries objectForKey:@"id"] integerValue]];
   [newTaskSeries setValue:iD forKey:@"iD"];
   NSDate *created = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"created"]];
   [newTaskSeries setValue:created forKey:@"created"];   
   [newTaskSeries setValue:listObject forKey:@"inList"];
   
   if ([taskseries objectForKey:@"modified"]) {
      NSDate *date = [[MilponHelper sharedHelper] rtmStringToDate:[taskseries objectForKey:@"modified"]];
      [newTaskSeries setValue:date forKey:@"modified"];
   }      
   if ([taskseries objectForKey:@"rrule"]) {
      NSDictionary *rrule = [taskseries objectForKey:@"rrule"];
      NSString *packedRrule = [NSString stringWithFormat:@"%@-%@", [rrule objectForKey:@"every"], [rrule objectForKey:@"rule"]];
      [newTaskSeries setValue:packedRrule forKey:@"rrule"];
   }

   if ([taskseries objectForKey:@"url"])
      [newTaskSeries setValue:[taskseries objectForKey:@"url"] forKey:@"url"];
   
   // setup Tasks in the TaskSeries
   for (NSDictionary *task in [taskseries objectForKey:@"tasks"]) {
      NSEntityDescription  *entity = [[fetchedResultsController fetchRequest] entity];
      NSManagedObject     *newTask = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];

      [newTask setValue:newTaskSeries forKey:@"taskSeries"];

      NSNumber *taskID = [NSNumber numberWithInteger:[[task objectForKey:@"id"] integerValue]];
      [newTask setValue:taskID forKey:@"iD"];

      if ([task objectForKey:@"added"]) {
         NSDate *addedDate = [[MilponHelper sharedHelper] rtmStringToDate:[task objectForKey:@"added"]];
         [newTask setValue:addedDate forKey:@"added"];
      }

      [newTask setValue:[self boolNumberFromString:[task objectForKey:@"has_due_time"]] forKey:@"has_due_time"];
      [newTask setValue:[self integerNumberFromString:[task objectForKey:@"postponed"]] forKey:@"postponed"];
      [newTask setValue:[self integerNumberFromString:[task objectForKey:@"priority"]] forKey:@"priority"];
   }
   
   // Save the context.
   NSError *error = nil;
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
   
   NSString *listString = [NSString stringWithFormat:@"%d", [[listObject valueForKey:@"iD"] integerValue]];
   NSArray *tasksRetrieved = [api getTaskList:listString filter:nil lastSync:nil];
   for (NSDictionary *taskseries in tasksRetrieved) {
      [self insertNewTask:taskseries];
   }
   
   [api release];
}

- (void) updateFetchRequestController
{
   [fetchedResultsController release];
   fetchedResultsController = nil;

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

- (void) toggleValueChanged:(id) sender
{
   UISwitch *toggleSwitch = (UISwitch *)sender;
   showToggle = toggleSwitch.on;
   [self updateFetchRequestController];
   [self.tableView reloadData];
}

@end