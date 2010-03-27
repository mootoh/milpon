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
   return vc;
}

@end // AppDelegate (Private)

@implementation AppDelegate

@synthesize window;
@synthesize auth;

/**
  * init DB and authorization info
  */
- (id) init
{
   if (self = [super init]) {
      self.auth = [[RTMAuth alloc] init];

      [RTMAPI setApiKey:auth.api_key];
      [RTMAPI setSecret:auth.shared_secret];
      if (auth.token)
         [RTMAPI setToken:auth.token];
      syncer = [[RTMSynchronizer alloc] initWithAuth:auth];
      syncer.delegate = self;
   }
   return self;
}

- (void) dealloc
{
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
   [rootViewController release];   

   navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [window addSubview:navigationController.view];

   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // get the settings prefs
   if ([defaults boolForKey:@"pref_sync_at_start"] && [self authorized])
      [syncer update];

   [window makeKeyAndVisible];
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
}

- (IBAction) showInfo
{
   // TODO: use in-app mail
   NSString *subject = [NSString stringWithFormat:@"subject=Milpon Feedback"];
   NSString *mailto = [NSString stringWithFormat:@"mailto:mootoh@gmail.com?%@", [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   NSURL *url = [NSURL URLWithString:mailto];
   [[UIApplication sharedApplication] openURL:url];
   return;
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

   UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                          [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease]];
   vc.navigationItem.titleView = iv;
   [collector release];
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:YES];
   [vc release];
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

   UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                          [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease]];
   vc.navigationItem.titleView = iv;
   
   [collector release];
   [navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:YES];
   [vc release];
}   

#pragma mark Sync

- (IBAction) update
{
   // show the progress view
   [syncer update];
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
   // dismiss the progress view
   [self reloadTableView];
}

- (void) didReplaceAll
{
   // dismiss the progress view
   [self reloadTableView];
}

@end