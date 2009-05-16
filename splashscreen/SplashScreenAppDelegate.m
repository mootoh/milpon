//
//  SplashScreenAppDelegate.m
//  Milpon
//
//  Created by Motohiro Takayama on 5/17/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "SplashScreenAppDelegate.h"
#import "SplashScreenViewController.h"

@implementation SplashScreenAppDelegate

@synthesize window, splashScreenViewController;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   self.splashScreenViewController = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:nil];
   [window addSubview:splashScreenViewController.view];
   
   [window makeKeyAndVisible];
}

@end
