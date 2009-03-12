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
#import "LocalCache.h"
#import "AuthViewController.h"
#import "RootViewController.h"
#import "AddTaskViewController.h"
#import "RTMSynchronizer.h"
#import "Reachability.h"
#import "logger.h"

@implementation AppDelegate

@synthesize window, auth, operationQueue, tabBarController;

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

      operationQueue = [[NSOperationQueue alloc] init];
   }
   return self;
}

- (void)dealloc
{
   [tabBarController release];
   [operationQueue release];
   [auth release];
   [window release];
   [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#define USE_AUTH
#ifdef USE_AUTH
   [window addSubview:tabBarController.view];

   if (!auth.token || [auth.token isEqualToString:@""]) {
      AuthViewController *avc = [[AuthViewController alloc] initWithNibName:nil bundle:nil];
      avc.navigationItem.hidesBackButton = YES;

      UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
      [tabBarController presentModalViewController:nc animated:NO];
      [nc release];
   }
#else // USE_AUTH
      RootViewController *root = [[RootViewController alloc] initWithNibName:nil bundle:nil];
      [window addSubview:root.view];
#endif // USE_AUTH

   [window makeKeyAndVisible];
}

- (IBAction) addTask
{
   AddTaskViewController *atvController = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];
   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [tabBarController presentModalViewController:navc animated:NO];
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
   [window addSubview:tabBarController.view];
   [window bringSubviewToFront:tabBarController.view];
   [[svs objectAtIndex:0] removeFromSuperview];
}

- (IBAction) fetchAll
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:auth];
   [syncer replaceLists];
   [syncer replaceTasks];
   //[syncer replaceLocations];
   //[syncer replaceNotes];
   //[syncer replaceTags];

   [syncer release];

   //[self reload];

   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction) refresh
{
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
      return;
   } else {
      LOG(@"OK");
   }

   //refreshButton.enabled = NO;
   //[progressView progressBegin];
   NSInvocationOperation *ope = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadOperation) object:nil];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [app.operationQueue addOperation:ope];
   [ope release];
}

- (void) uploadOperation
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:auth];

   /*
   [syncer uploadPendingTasks:progressView];
   [syncer syncModifiedTasks:progressView];
   [syncer syncTasks:progressView];
   */
   [syncer uploadPendingTasks:nil];
   [syncer syncModifiedTasks:nil];
   [syncer syncTasks:nil];

   [syncer release];

   //[self reload];

   NSString *lastUpdated = [[LocalCache sharedLocalCache] lastSync];
   lastUpdated = [lastUpdated stringByReplacingOccurrencesOfString:@"T" withString:@"_"];
   lastUpdated = [lastUpdated stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];

   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

   NSDate *lu = [formatter dateFromString:lastUpdated];
   [formatter setDateFormat:@"MM/dd HH:mm"];
   lastUpdated = [formatter stringFromDate:lu];

   //[progressView updateMessage:[NSString stringWithFormat:@"Updated: %@", lastUpdated]];

   //[progressView progressEnd];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   //refreshButton.enabled = YES;
}

@end
