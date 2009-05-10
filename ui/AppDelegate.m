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
#import "AddTaskViewController.h"
#import "RootMenuViewController.h"
#import "OverviewViewController.h"
#import "RTMSynchronizer.h"
#import "Reachability.h"
#import "ProgressView.h"
#import "logger.h"

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
   [navigationController presentModalViewController:nc animated:NO];
   [nc release];
}

- (void) recoverView
{
   // determine which view to be recovered
   OverviewViewController *hvc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];

   // recover it
   [navigationController pushViewController:hvc animated:NO];
   [hvc release];
}

@end // AppDelegate (Private)

@implementation AppDelegate

@synthesize window, auth, operationQueue;

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

- (void) dealloc
{
   [navigationController release];
   [operationQueue release];
   [auth release];
   [window release];
   [super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   RootMenuViewController *rmvc = [[RootMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
   navigationController = [[UINavigationController alloc] initWithRootViewController:rmvc];
   [rmvc release];
   navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0f green:51.0f/256.0f blue:102.0f/256.0f alpha:1.0];

   [window addSubview:navigationController.view];

   if (!auth.token || [auth.token isEqualToString:@""])
      [self showAuthentication];

   [self recoverView];
   [window makeKeyAndVisible];
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
      return;
   } else {
      LOG(@"OK");
   }
#endif // 0
   //refreshButton.enabled = NO;
   //[progressView progressBegin];
   NSInvocationOperation *ope = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadOperation) object:nil];
   //NSInvocationOperation *ope = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(replaceAll) object:nil];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [app.operationQueue addOperation:ope];
   [ope release];
}
 
- (void) replaceAll
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [app fetchAll];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// TODO: shows CoreAnimation animated progressbar
- (void) uploadOperation
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:auth];

   [syncer uploadPendingTasks:nil];
#if 0 // 20090502
   [syncer syncModifiedTasks:nil];
   [syncer syncTasks:nil];
#endif // 0
   [syncer release];

   //[self reload];

#if 0
   NSString *lastUpdated = [[LocalCache sharedLocalCache] lastSync];
   lastUpdated = [lastUpdated stringByReplacingOccurrencesOfString:@"T" withString:@"_"];
   lastUpdated = [lastUpdated stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];

   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

   NSDate *lu = [formatter dateFromString:lastUpdated];
   [formatter setDateFormat:@"MM/dd HH:mm"];
   lastUpdated = [formatter stringFromDate:lu];

   [progressView updateMessage:[NSString stringWithFormat:@"Updated: %@", lastUpdated]];
#endif // 0

   //[progressView progressEnd];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   //refreshButton.enabled = YES;
}

- (IBAction) showDialog
{
   // setup ProgressView
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   ProgressView *pv = [[ProgressView alloc] initWithFrame:CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100)];
   pv.alpha = 0.0f;
   pv.backgroundColor = [UIColor blackColor];
   pv.opaque = YES;
   [window addSubview:pv];

   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];

      pv.alpha = 0.8f;
      pv.frame = CGRectMake(appFrame.origin.x, appFrame.size.height-80, appFrame.size.width, 100);
   } [UIView commitAnimations];
   
   [pv toggleDisplay];
   [pv release];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
   NSLog(@"dialogAnimDidStop");
}

@end