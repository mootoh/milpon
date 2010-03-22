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
#import "RTMSynchronizer.h"
#import "Reachability.h"
#import "ProgressView.h"
#import "LocalCache.h"
#import "logger.h"
#import "TaskProvider.h"
#import "MilponHelper.h"
#import "ListProvider.h"

@interface AppDelegate (Private)
- (NSString *) authPath;
- (void) authInit:(NSString *)path;
- (void) showAuthentication;
- (void) recoverView;
@end // AppDelegate (Private)

@implementation AppDelegate (Private)

- (NSString *) authPath
{
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *documentDirectory = [paths objectAtIndex:0];
   NSString *path = [documentDirectory stringByAppendingPathComponent:@"auth.dat"];
   return path;
}

- (void) authInit:(NSString *)path
{
   NSFileManager *fm = [NSFileManager defaultManager];
   if ([fm fileExistsAtPath:path]) {
      NSMutableData *data = [NSMutableData dataWithContentsOfFile:path];
      NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
      self.auth = [decoder decodeObjectForKey:@"auth"];
      [decoder finishDecoding];
      [decoder release];
   } else {
      self.auth = [[RTMAuth alloc] init];
   }
}

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

@synthesize window, auth;

/**
  * init DB and authorization info
  */
- (id) init
{
   if (self = [super init]) {
      [self authInit:[self authPath]];

      [RTMAPI setApiKey:auth.api_key];
      [RTMAPI setSecret:auth.shared_secret];
      if (auth.token)
         [RTMAPI setToken:auth.token];
   }
   return self;
}

- (void) dealloc
{
   [pv release];
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

- (NSInteger) todayTaskCount
{
   NSMutableArray *todayTasks = [NSMutableArray array];
   
   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];
   
   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
   
   NSDate *today = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
                                              [comps year], [comps month], [comps day]]];
   
   NSArray *tasks = [[TaskProvider sharedTaskProvider] tasks:NO];
   for (RTMTask *task in tasks) {
      if (!task.due || task.due == [MilponHelper sharedHelper].invalidDate) continue;
      NSDateComponents *comp_due = [calendar components:unitFlags fromDate:task.due];
      NSDate *due_date = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
                                                    [comp_due year], [comp_due month], [comp_due day]]];
      
      NSTimeInterval interval = [due_date timeIntervalSinceDate:today];
      if (0 <= interval && interval < 24*60*60)
         [todayTasks addObject:task];
   }
   return [todayTasks count];
}

- (NSInteger) remainTaskCount
{
   NSMutableArray *remainTasks = [NSMutableArray array];

   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSDateComponents *comps = [calendar components:unitFlags fromDate:now];

   NSDate *today = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
                                              [comps year], [comps month], [comps day]]];

   NSArray *tasks = [[TaskProvider sharedTaskProvider] tasks:NO];
   for (RTMTask *task in tasks) {
      if (!task.due || task.due == [MilponHelper sharedHelper].invalidDate) continue;
      NSDateComponents *comp_due = [calendar components:unitFlags fromDate:task.due];
      NSDate *due_date = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
                                                    [comp_due year], [comp_due month], [comp_due day]]];

      NSTimeInterval interval = [due_date timeIntervalSinceDate:today];
      if (interval < 0 || interval < 24*60*60)
          [remainTasks addObject:task];
   }
   return [remainTasks count];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
   NSInteger badgeCount = 0;
   switch([[NSUserDefaults standardUserDefaults] integerForKey:@"pref_badge_source"]) {
      case BADGE_INBOX:
         badgeCount = [self inboxTaskCount];
         break;
      case BADGE_TODAY:
         badgeCount = [self todayTaskCount];
         break;
      case BADGE_REMAINS:
         badgeCount = [self remainTaskCount];
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

- (IBAction) saveAuth
{
   NSMutableData *theData = [NSMutableData data];
   NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];

   [encoder encodeObject:auth forKey:@"auth"];
   [encoder finishEncoding];

   [theData writeToFile:[self authPath] atomically:YES];
   [encoder release];
}

- (IBAction) authDone
{
   NSArray *svs = window.subviews;
   NSAssert(svs.count == 1, @"should be only avc");
   [window addSubview:navigationController.view];
   [window bringSubviewToFront:navigationController.view];
   [[svs objectAtIndex:0] removeFromSuperview];
}

@end