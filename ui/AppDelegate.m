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
#import "RootMenuViewController.h"
#import "OverviewViewController.h"
#import "UpgradeFetchAllViewController.h"
#import "LocalCache.h"
#import "logger.h"
#import "TaskProvider.h"
#import "ListProvider.h"
#import "MilponHelper.h"

@interface AppDelegate (Private)
- (void) showAuthentication;
- (void) recoverView;
@end // AppDelegate (Private)

@implementation AppDelegate (Private)

- (void) showAuthentication
{
   AuthViewController *avc = [[AuthViewController alloc] initWithNibName:nil bundle:nil];
   avc.navigationItem.hidesBackButton = YES;
   
   UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
   [avc release];
   [navigationController presentModalViewController:nc animated:NO];
   [nc release];
}

- (void) recoverView
{
   // TODO: determine which view to be recovered
   OverviewViewController *hvc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];

   // recover it
   [navigationController pushViewController:hvc animated:NO];
   [hvc release];
}

- (void) showUpgradeFetchAllView
{
   UpgradeFetchAllViewController *ufavc = [[UpgradeFetchAllViewController alloc] initWithNibName:nil bundle:nil];
   
   UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ufavc];
   [navigationController presentModalViewController:nc animated:NO];
   [nc release];
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
   }
   return self;
}

- (void) dealloc
{
   [navigationController release];
   [auth release];
   [window release];
   [super dealloc];
}

#define VERSION_1_0_MIGRATE_NUMBER 4
- (BOOL) migrate:(LocalCache *)local_cache
{
   BOOL upgraded_from_1_0 = NO;
   if ([local_cache current_migrate_version] == VERSION_1_0_MIGRATE_NUMBER) {
      upgraded_from_1_0 = YES;
      [local_cache upgrade_from_1_0_to_2_0];
   }
   [local_cache migrate];
   return upgraded_from_1_0;
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   LocalCache *local_cache = [LocalCache sharedLocalCache];
   BOOL upgraded = [self migrate:local_cache];
   
   RootMenuViewController *rmvc = [[RootMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
   navigationController = [[UINavigationController alloc] initWithRootViewController:rmvc];
   [rmvc release];

   navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [window addSubview:navigationController.view];
   
   if (!auth.token || [auth.token isEqualToString:@""]) {
      [self showAuthentication];
      [self recoverView];
   } else {
      if (upgraded) {
         [self showUpgradeFetchAllView];
      } else {
         [self recoverView];
      }
   }

   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // get the settings prefs
   if ([defaults boolForKey:@"pref_sync_at_start"])
      [rmvc refresh];

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

@end