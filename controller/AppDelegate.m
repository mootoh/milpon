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
#import "RTMDatabase.h"
#import "AuthViewController.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window, auth, db, operationQueue;

- (id)init {
  if (self = [super init]) {
    db   = [[RTMDatabase alloc] init];
    auth = [[RTMAuth alloc] initWithDB:db];
	  [RTMAPI setApiKey:auth.api_key];
	  [RTMAPI setSecret:auth.shared_secret];
    if (auth.token)
      [RTMAPI setToken:auth.token];
    operationQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

- (void)dealloc {
  [operationQueue release];
  [auth release];
  [db release];
  [window release];
  [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  RootViewController *root = [[RootViewController alloc] initWithNibName:nil bundle:nil];
  [window addSubview:root.view];
  [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Save data if appropriate
}

/*
 * UIApplicationDelegate methods
 */
#if 0
– application:willChangeStatusBarOrientation:duration:
– application:didChangeStatusBarOrientation:
– applicationWillResignActive:
– applicationDidBecomeActive:
– application:willChangeStatusBarFrame:
– application:didChangeStatusBarFrame:
– applicationDidReceiveMemoryWarning:
– applicationSignificantTimeChange:
#endif // 0

@end
