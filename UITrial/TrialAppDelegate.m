//
//  TrialAppDelegate.m
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TrialAppDelegate.h"


@implementation TrialAppDelegate
@synthesize window, tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   [window addSubview:tabBarController.view];
   [window makeKeyAndVisible];
}


- (void)dealloc
{
   [tabBarController release];
   [window release];
   [super dealloc];
}

@end
