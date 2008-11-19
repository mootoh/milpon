//
//  FunctionalTestAppDelegate.m
//  Milpon
//
//  Created by Motohiro Takayama on 11/19/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "FunctionalTestAppDelegate.h"
#import "ProgressViewController.h"

@implementation FunctionalTestAppDelegate

@synthesize window;

- (void) dealloc
{
   [window release];
   [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   ProgressViewController *pvc = [[ProgressViewController alloc] initWithNibName:nil bundle:nil];
   [window addSubview:pvc.view];
   [window makeKeyAndVisible];
}

@end
