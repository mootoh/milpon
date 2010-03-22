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

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if (section == 0)
      return SEC_ZERO_COUNT;
   if (section == 1)
      return SEC_ONE_COUNT;
   return 0;
}

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