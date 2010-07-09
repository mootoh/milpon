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
#import "MPListMediator.h"
#import "MPTaskMediator.h"
#import "MPAppDelegate.h"
#import "MPHelper.h"
#import "MPLogger.h"

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

#pragma mark  -
@implementation MPListViewController

@synthesize fetchedResultsController, managedObjectContext;

- (void) setupToolbar
{
   MPAppDelegate *app = (MPAppDelegate *)[UIApplication sharedApplication].delegate;
   UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sync)];
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(showAddTask)];
   
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   UIBarButtonItem *tightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   tightSpace.width = 20.0f;
   
   UIBarButtonItem *overviewButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_overview_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToOverview)];
   UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToList)];
   UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_tag_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToTag)];
   
   self.toolbarItems = [NSArray arrayWithObjects:refreshButton, flexibleSpace, overviewButton, tightSpace, listButton, tightSpace, tagButton, flexibleSpace, addButton, nil];
   self.navigationController.toolbar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [addButton release];
   [listButton release];
   [tagButton release];
   [overviewButton release];
   [tightSpace release];
   [flexibleSpace release];
   [refreshButton release];   
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = @"Lists";

   // fetch Lists
   NSError *error = nil;
   if (![self.fetchedResultsController performFetch:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }

   listMediator = [[MPListMediator alloc] initWithManagedObjectContext:self.managedObjectContext];
   taskMediator = [[MPTaskMediator alloc] initWithManagedObjectContext:self.managedObjectContext];

   [self setupToolbar];
}

#pragma mark -
#pragma mark Table view data source

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
   [fetchedResultsController release];
   [managedObjectContext release];
   [listMediator release];
   [taskMediator release];
   
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
- (void) sync
{
   RTMAPI *api = [[RTMAPI alloc] init];
   if (api.token == nil) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"no token" message:@"no token" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [av show];
      [av release];
      [api release];
      return;
   }

   [listMediator sync:api];
   [taskMediator sync:api];

   [api release];
   
   // update lastSyncDate now.
}
@end