//
//  RootViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"

@implementation RootViewController


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void) setupToolbar
{
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:app action:@selector(update)];
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(addTask)];
   
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   UIBarButtonItem *tightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   tightSpace.width = 20.0f;
   
   UIBarButtonItem *overviewButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_calendar.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToOverview)];
   UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToList)];
   UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_tag.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToTag)];
   
   self.toolbarItems = [NSArray arrayWithObjects:refreshButton, flexibleSpace, overviewButton, tightSpace, listButton, tightSpace, tagButton, flexibleSpace, addButton, nil];
   self.navigationController.toolbar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [self.navigationController setToolbarHidden:NO];
   [addButton release];
   [overviewButton release];
   [tightSpace release];
   [flexibleSpace release];
   [refreshButton release];   
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self setupToolbar];
}

- (void) viewWillDisappear:(BOOL)animated
{
   [super viewDidAppear:animated];
   self.navigationItem.rightBarButtonItem = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"info" style:UIBarButtonItemStylePlain target:app action:@selector(showInfo)];
   self.navigationItem.rightBarButtonItem = infoButton;
   [infoButton release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [super dealloc];
}

#pragma mark Others

- (void) reloadFromDB
{
}

#pragma mark TODO
#if 0
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
   [[NSNotificationCenter defaultCenter] postNotificationName:@"didRefresh" object:nil];
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

- (void) showFetchAllModal
{
   RefreshingViewController *vc = [[RefreshingViewController alloc] initWithNibName:@"RefreshingViewController" bundle:nil];
   vc.rootMenuViewController = self;
   [self.view.window addSubview:vc.view];
   [vc.view setNeedsDisplay];
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
#endif // 0
@end