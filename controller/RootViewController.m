//
//  RootViewController.m
//  Milpon
//
//  Created by mootoh on 10/17/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RootViewController.h"
#import "ListViewController.h"
#import "MenuViewController.h"
#import "AddTaskViewController.h"
#import "RTMSynchronizer.h"
#import "RTMDatabase.h"
#import "AppDelegate.h"
#import "AuthViewController.h"
#import "RTMAuth.h"
#import "ProgressView.h"
#import "ReloadableTableViewController.h"

/* -------------------------------------------------------------------
 * RootViewController
 */
@implementation RootViewController

@synthesize navigationController, bottomBar, progressView;

- (void)dealloc {
  [progressView release];
  [bottomBar release];
  [navigationController release];
  [super dealloc];
}


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
  [super loadView];

  CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	const CGFloat toolbarHeight = 44;

  // create a top ViewController.
  MenuViewController *menuViewController = [[MenuViewController alloc] initWithStyle:UITableViewStylePlain];
  menuViewController.rootViewController = self;

  // create a NavigationController.
  UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
  naviController.view.frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height-toolbarHeight);
  naviController.view.backgroundColor = [UIColor greenColor];
  [self.view addSubview:naviController.view];
  self.navigationController = naviController;

  // create a bottom bar.
  UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(appFrame.origin.x, appFrame.size.height-toolbarHeight, appFrame.size.width, toolbarHeight)];
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask)];
  UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(upload)];

  ProgressView *pv = [[ProgressView alloc] initWithFrame:CGRectMake(8, 8, 240, 36)];
  UIBarButtonItem *progressIndicator = [[UIBarButtonItem alloc] initWithCustomView:pv];
  self.progressView = pv;

  [bar setItems:[NSArray arrayWithObjects:uploadButton, progressIndicator, addButton, nil] animated:NO];

  [self.view addSubview:bar];
  self.bottomBar = bar;
  menuViewController.bottomBar = self.bottomBar;

  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  if (!app.auth.token || [app.auth.token isEqualToString:@""]) {
    AuthViewController *avc = [[AuthViewController alloc] initWithNibName:nil bundle:nil];
    avc.rootViewController = self;

    avc.navigationItem.hidesBackButton = YES;
    avc.bottomBar = bottomBar;
    bottomBar.hidden = YES;
    [naviController pushViewController:avc animated:NO];

    [avc release];
  }
  [menuViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (IBAction) addTask {
  CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
  
  self.bottomBar.hidden = YES;

  AddTaskViewController *ctrl = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];

  UINavigationController *modalController = [[UINavigationController alloc] initWithRootViewController:ctrl];
  modalController.view.frame = CGRectMake(0, 44, appFrame.size.width, appFrame.size.height-44);
  [self presentModalViewController:modalController animated:YES];
  [modalController release];
  [ctrl release];
}

- (void) reload {
  UIViewController *tvc = navigationController.topViewController;
  if ([tvc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
    [(UITableViewController<ReloadableTableViewControllerProtocol> *)tvc reloadFromDB];
    [((UITableViewController *)tvc).tableView reloadData];
  }
}

- (IBAction) upload {
  NSInvocationOperation *ope = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadOperation) object:nil];
  
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app.operationQueue addOperation:ope];
}

- (void) uploadOperation {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  RTMSynchronizer *syncer = [[[RTMSynchronizer alloc] initWithDB:app.db withAuth:app.auth] autorelease];
  [syncer uploadPendingTasks:progressView];
  [syncer syncCompletedTasks];
  [syncer syncTasks];
  
  [self reload];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) fetchAll {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  RTMSynchronizer *syncer = [[[RTMSynchronizer alloc] initWithDB:app.db withAuth:app.auth] autorelease];
  [syncer replaceLists];
  [syncer replaceTasks];

  [self reload];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [navigationController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [navigationController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [navigationController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [navigationController viewDidDisappear:animated];
}

@end
