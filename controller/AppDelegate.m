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

- (NSString *) authPath
{
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *documentDirectory = [paths objectAtIndex:0];
   NSString *path = [documentDirectory stringByAppendingPathComponent:@"auth.dat"];
   return path;
}

- (id) init
{
  if (self = [super init]) {
    db = [[RTMDatabase alloc] init];

    NSString *path = [self authPath];
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
   NSMutableData *theData = [NSMutableData data];
   NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];

   [encoder encodeObject:auth forKey:@"auth"];
   [encoder finishEncoding];

   [theData writeToFile:[self authPath] atomically:YES];
   [encoder release];
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
