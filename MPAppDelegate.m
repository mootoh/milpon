//
//  MPAppDelegate.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPAppDelegate.h"


@implementation MPAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
   // if not authorized
   //   get token
   [window addSubview:navigationController.view];
   [window makeKeyAndVisible];
}

@end