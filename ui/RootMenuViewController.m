//
//  RootMenuViewController.m
//  Milpon
//
//  Created by mootoh on 4/12/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "RootMenuViewController.h"
#import "OverviewViewController.h"
#import "TaskCollection.h"
#import "TaskCollectionViewController.h"
#import "AppDelegate.h"
#import "ReviewViewController.h"
#import "ConfigViewController.h"
#import "RTMSynchronizer.h"
#import "Reachability.h"
#import "ProgressView.h"

@implementation RootMenuViewController

enum sec_zero {
   SEC_ZERO_OVERVIEW,
   SEC_ZERO_LIST,
   SEC_ZERO_TAG,
   SEC_ZERO_COUNT
};

enum sec_one {
   //SEC_ONE_REVIEW,
   SEC_ONE_MORE,
   SEC_ONE_COUNT
};

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAll) name:@"fetchAll" object:nil];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = NSLocalizedString(@"Milpon", @"");

   refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
   

   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv = [[ProgressView alloc] initWithFrame:CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100)];
   pv.tag = PROGRESSVIEW_TAG;
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [ad.window addSubview:pv];
   
   UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   taskLabel.text = @"Task";
   self.tableView.tableHeaderView = taskLabel;
   [taskLabel release];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(addTask)];
   
   self.navigationItem.rightBarButtonItem = addButton;
   self.navigationItem.leftBarButtonItem  = refreshButton;

   [addButton release];

   self.tableView.scrollEnabled = NO;
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

- (void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];

   // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload {
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if (section == 0)
      return SEC_ZERO_COUNT;
   if (section == 1)
      return SEC_ONE_COUNT;
   return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"RootMenuCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }

   if (indexPath.section == 0) {
      switch (indexPath.row) {
         case SEC_ZERO_OVERVIEW: {
         cell.textLabel.text =  NSLocalizedString(@"Overview", @"");
         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]] autorelease];
         break;
      }
      case SEC_ZERO_LIST: {
         cell.textLabel.text =  NSLocalizedString(@"List", @"");

         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease];
         break;
      }
      case SEC_ZERO_TAG: {
         cell.textLabel.text =  NSLocalizedString(@"Tag", @"");
         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease];

         break;
      }
      default:
         break;
      }
   } else {
      switch (indexPath.row) {
#if 0
      case SEC_ONE_REVIEW:
         cell.text = @"Review";
         cell.textColor = [UIColor grayColor];
         break;
#endif // 0
      case SEC_ONE_MORE:
         cell.textLabel.text =  NSLocalizedString(@"More", @"");
         break;
      default:
         break;
      }
   }

   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Navigation logic may go here. Create and push another view controller.
   // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
   // [self.navigationController pushViewController:anotherViewController];
   // [anotherViewController release];

   UIViewController *vc = nil;

   if (indexPath.section == 0) {
      switch (indexPath.row) {
      case SEC_ZERO_OVERVIEW:
         vc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];
         break;
      case SEC_ZERO_LIST: {
         vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
         ListTaskCollection *collector = [[ListTaskCollection alloc] init];
         [(TaskCollectionViewController *)vc setCollector:collector];

         //vc.title = @"List";
         UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease]];
         vc.navigationItem.titleView = iv;

         [collector release];
         break;
      }
      case SEC_ZERO_TAG: {
         vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
         TagTaskCollection *collector = [[TagTaskCollection alloc] init];
         [(TaskCollectionViewController *)vc setCollector:collector];
         //vc.title = @"Tag";
         UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                                [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease]];
         vc.navigationItem.titleView = iv;

         [collector release];   
         break;
      }
      default:
         break;
      }
   } else {
      switch (indexPath.row) {
#if 0
      case SEC_ONE_REVIEW:
         //vc = [[ReviewViewController alloc] initWithStyle:UITableViewStylePlain];
         //break;
         return; // TODO:temporally
#endif // 0
      case SEC_ONE_MORE:
         vc = [[ConfigViewController alloc] initWithNibName:nil bundle:nil];
         break;
      default:
         break;
      }
   }

   NSAssert(vc != nil, @"should be set some ViewController.");

   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return section == 0 ? NSLocalizedString(@"Task", @"") : nil;
}

- (void)dealloc
{
   [refreshButton release];
   [super dealloc];
}


- (IBAction) fetchAll
{
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:ad.auth];
   [syncer replaceLists];
   [syncer replaceTasks];
   
   [syncer release];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   [[NSNotificationCenter defaultCenter] postNotificationName:@"didFetchAll" object:nil];
}

- (BOOL) is_reachable
{
#ifndef LOCAL_DEBUG
   Reachability *reach = [Reachability sharedReachability];
   reach.hostName = @"api.rememberthemilk.com";
   NetworkStatus stat =  [reach internetConnectionStatus];
   reach.networkStatusNotificationsEnabled = NO;
   if (stat == NotReachable) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Connected"
                                                   message:@"Not connected to the RTM site. Sync when you are online."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
      [av release];
      return NO;
   }
#endif // LOCAL_DEBUG
   return YES;
}

- (IBAction) refresh
{
   if (! [self is_reachable]) return;
   
   refreshButton.enabled = NO;
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   [self showDialog];
   
   [self performSelectorInBackground:@selector(uploadOperation) withObject:nil];
}

- (void) uploadOperation
{
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:ad.auth];
   
   [syncer uploadPendingTasks:pv];
   [syncer syncModifiedTasks:pv];
   [syncer syncTasks:pv];
   [syncer release];
   
   [self performSelectorOnMainThread:@selector(refreshView) withObject:nil waitUntilDone:YES];
   [self performSelectorOnMainThread:@selector(hideDialog) withObject:nil waitUntilDone:YES];
}

- (void) refreshView
{
   UIViewController *vc = self.navigationController.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
   
}

- (IBAction) showDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv.alpha = 0.0f;
   pv.backgroundColor = [UIColor blackColor];
   pv.opaque = YES;
   pv.message = @"Syncing...";
   
   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];
      
      pv.alpha = 0.8f;
      pv.frame = CGRectMake(appFrame.origin.x, appFrame.size.height-80, appFrame.size.width, 100);
   } [UIView commitAnimations];
}

- (IBAction) hideDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv.message = @"Synced.";
   
   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];
      
      pv.alpha = 0.0f;
      pv.frame = CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100);
   } [UIView commitAnimations];
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   refreshButton.enabled = YES;
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [ad.window setNeedsDisplay];
}

@end