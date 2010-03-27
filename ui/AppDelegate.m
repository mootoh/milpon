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
#import "LocalCache.h"
#import "logger.h"
#import "TaskProvider.h"
#import "ListProvider.h"
#import "MilponHelper.h"

@interface AppDelegate (Private)
- (UIViewController *) recoverViewController;
@end // AppDelegate (Private)

@implementation AppDelegate (Private)

- (UIViewController *) recoverViewController
{
   UIViewController *vc = nil;
   
   if (!auth.token || [auth.token isEqualToString:@""]) {
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

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   UIViewController *rootViewController = [self recoverViewController];
   navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
   [rootViewController release];   

   navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [window addSubview:navigationController.view];

//   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // get the settings prefs
//   if ([defaults boolForKey:@"pref_sync_at_start"])
//      [rmvc refresh];

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

@end