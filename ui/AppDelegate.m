//
//  AppDelegate.m
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

#import "AppDelegate.h"
#import "RTMAPI.h"
#import "RTMAuth.h"
#import "RTMTask.h"
#import "RTMList.h"
#import "AuthViewController.h"
#import "AddTaskViewController.h"
#import "OverviewViewController.h"
#import "LocalCache.h"
#import "logger.h"
#import "TaskProvider.h"
#import "ListProvider.h"
#import "MilponHelper.h"
#import "TaskCollectionViewController.h"
#import "TaskCollection.h"
#import "ProgressView.h"
#import "InfoViewController.h"
#import "RefreshingViewController.h"
#import "TaskListViewController.h"
#import "PrivateInfo.h"

@interface AppDelegate (Private)
- (UIViewController *) recoverViewController;
- (BOOL) authorized;
@end // AppDelegate (Private)

@implementation AppDelegate (Private)

- (BOOL) authorized
{
   return auth.token && ![auth.token isEqualToString:@""];
}

- (UIViewController *) recoverViewController
{
   UIViewController *vc = nil;
   
   if (! [self authorized]) {
      vc = [[AuthViewController alloc] initWithNibName:@"AuthView" bundle:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedAuthorization) name:@"backToRootMenu" object:nil];
   } else {
      // TODO: determine which view to be recovered
      vc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];
   }
   NSAssert(vc, @"check ViewController");
   return [vc autorelease];
}

@end // AppDelegate (Private)

@implementation AppDelegate

@synthesize window;
@synthesize auth;
@synthesize syncer;

const CGFloat arrowXs[] = {
   160-53,
   160,
   160+53,
};

const CGFloat arrowY = 480-44-3;

/**
  * init DB and authorization info
  */
- (id) init
{
   if (self = [super init]) {
      RTMAuth *ath =[[RTMAuth alloc] init];
      self.auth = ath;
      [ath release];

      [RTMAPI setApiKey:auth.api_key];
      [RTMAPI setSecret:auth.shared_secret];
      if (auth.token)
         [RTMAPI setToken:auth.token];
      syncer = [[RTMSynchronizer alloc] initWithAuth:auth];
      syncer.delegate = self;
      refreshingViewController = nil;
   }
   return self;
}

- (void) dealloc
{
   [refreshingViewController release];
   [arrowImageView release];
   [progressView release];
   [navigationController release];
   [syncer release];
   [auth release];
   [window release];
   [super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   UIViewController *rootViewController = [self recoverViewController];
   navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

   navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [window addSubview:navigationController.view];

   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   progressView = [[ProgressView alloc] initWithFrame:CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100)];
   progressView.tag = PROGRESSVIEW_TAG;
   [window addSubview:progressView];
   
   arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
   [navigationController.view addSubview:arrowImageView];
   arrowImageView.center = CGPointMake(arrowXs[0], arrowY);
   
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // get the settings prefs
   if ([defaults boolForKey:@"pref_sync_at_start"] && [self authorized])
      [self update];

   [window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
   return YES;
}

enum {
   BADGE_INBOX = 0,
   BADGE_TODAY = 1,
   BADGE_REMAINS = 2
};

- (NSInteger) inboxTaskCount
{
   RTMList *inboxList = [[ListProvider sharedListProvider] inboxList];
   NSArray *tasks = [[TaskProvider sharedTaskProvider] tasksInList:inboxList.iD showCompleted:NO];
   return [tasks count];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
   NSInteger badgeCount = 0;
   switch([[NSUserDefaults standardUserDefaults] integerForKey:@"pref_badge_source"]) {
      case BADGE_INBOX:
         badgeCount = [self inboxTaskCount];
         break;
      case BADGE_TODAY:
         badgeCount = [[TaskProvider sharedTaskProvider] todayTaskCount];
         break;
      case BADGE_REMAINS:
         badgeCount = [[TaskProvider sharedTaskProvider] remainTaskCount];
         break;
      default:
         break;
   }

   [application setApplicationIconBadgeNumber:badgeCount];
}

- (IBAction) addTask
{
   AddTaskViewController *atvController = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];

   if ([navigationController.topViewController isKindOfClass:[TaskListViewController class]]) {
      TaskListViewController *tlvc = (TaskListViewController *)navigationController.topViewController;
      id item = tlvc.collection;
      if ([item isKindOfClass:[RTMList class]]) {
         atvController.list = (RTMList *)tlvc.collection;
      } else { // tag
         [atvController.tags addObject:(RTMTag *)tlvc.collection];
      }
   }

   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [navigationController presentModalViewController:navc animated:NO];
   [navc release];
   [atvController release];
}

- (IBAction) finishedAuthorization
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"backToRootMenu" object:nil];

   UIViewController *vc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];   
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:NO];
   [vc release];
}

- (IBAction) showInfo
{
   InfoViewController *ivc = [[InfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
   UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ivc];
   [navigationController presentModalViewController:nc animated:YES];
   [nc release];
   [ivc release];
}

#pragma mark switch views

- (void) switchToOverview
{
   // skip if already overview
   UIViewController *topVC = navigationController.topViewController;
   if ([topVC isKindOfClass:[OverviewViewController class]])
      return;

   // transit to overview
   OverviewViewController *vc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:YES];
   [vc release];

   [UIView beginAnimations:@"moveArrow" context:nil];
   arrowImageView.center = CGPointMake(arrowXs[0], arrowY);
   [UIView commitAnimations];
}

- (void) switchToList
{
   // skip if already list
   UIViewController *topVC = navigationController.topViewController;
   if ([topVC isKindOfClass:[TaskCollectionViewController class]] && [((TaskCollectionViewController *)topVC).collector isKindOfClass:[ListTaskCollection class]])
      return;

   // transit to list
   TaskCollectionViewController *vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
   ListTaskCollection *collector = [[ListTaskCollection alloc] init];
   [(TaskCollectionViewController *)vc setCollector:collector];
   [collector release];

   UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                          [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease]];
   vc.navigationItem.titleView = iv;
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:YES];
   [vc release];
   
   [UIView beginAnimations:@"moveArrow" context:nil];
   arrowImageView.center = CGPointMake(arrowXs[1], arrowY);
   [UIView commitAnimations];
}

- (void) switchToTag
{
   // skip if already tag
   UIViewController *topVC = navigationController.topViewController;
   if ([topVC isKindOfClass:[TaskCollectionViewController class]] && [((TaskCollectionViewController *)topVC).collector isKindOfClass:[TagTaskCollection class]])
      return;

   TaskCollectionViewController *vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
   TagTaskCollection *collector = [[TagTaskCollection alloc] init];
   [(TaskCollectionViewController *)vc setCollector:collector];
   [collector release];

   UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                          [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease]];
   vc.navigationItem.titleView = iv;
   
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:YES];
   [vc release];
   
   [UIView beginAnimations:@"moveArrow" context:nil];
   arrowImageView.center = CGPointMake(arrowXs[2], arrowY);
   [UIView commitAnimations];
}   

#pragma mark Sync

- (IBAction) showDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   progressView.alpha = 0.0f;
   progressView.backgroundColor = [UIColor blackColor];
   progressView.opaque = YES;
   progressView.message = @"Syncing...";

   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];

      progressView.alpha = 0.8f;
      progressView.frame = CGRectMake(appFrame.origin.x, appFrame.size.height-80, appFrame.size.width, 100);
   } [UIView commitAnimations];
}

- (IBAction) hideDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   progressView.message = @"Synced.";

   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];

      progressView.alpha = 0.0f;
      progressView.frame = CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100);
   } [UIView commitAnimations];

   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//   refreshButton.enabled = YES;
   [window setNeedsDisplay];
}

- (void) showFetchAllModal
{
   NSAssert(refreshingViewController == nil, @"state check");
   refreshingViewController = [[RefreshingViewController alloc] initWithNibName:@"RefreshingViewController" bundle:nil];
   [window addSubview:refreshingViewController.view];
   [refreshingViewController.view setNeedsDisplay];
}

- (IBAction) update
{
   if (! [syncer is_reachable]) return;

   // show the progress view
   [self showDialog];
   [syncer update:progressView];
}

- (IBAction) replaceAll
{
   if (! [syncer is_reachable]) return;
   [self showFetchAllModal];
   //[syncer replaceAll];
}

- (void)refreshingViewAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   [syncer performSelectorInBackground:@selector(replaceAll) withObject:nil];
}

- (void) reloadTableView
{
   UIViewController *vc = navigationController.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
}

#pragma mark RTMSynchronizerDelegate

- (void) didUpdate
{
   [self reloadTableView];
   // dismiss the progress view
   [self performSelectorOnMainThread:@selector(hideDialog) withObject:nil waitUntilDone:YES];
}

- (void) didReplaceAll
{
   [refreshingViewController didRefreshed];
   [refreshingViewController release];
   refreshingViewController = nil;
   [self reloadTableView];
}

# pragma mark others

- (void) showArrow
{
   arrowImageView.alpha = 0.0f;
   [UIView beginAnimations:@"showArrow" context:nil];
   arrowImageView.alpha = 1.0f;
   [UIView commitAnimations];
}

- (void) hideArrow
{
   arrowImageView.alpha = 1.0f;
   [UIView beginAnimations:@"showArrow" context:nil];
   arrowImageView.alpha = 0.0f;
   [UIView commitAnimations];
}

@end