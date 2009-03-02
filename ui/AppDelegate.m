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
#import "AddTaskViewController.h"

@implementation AppDelegate

@synthesize window, auth, db, operationQueue, tabBarController;

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
      db = [[RTMDatabase alloc] init];

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
   [db release];
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
      NSLog(@"nc = %p", nc);
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

@end
