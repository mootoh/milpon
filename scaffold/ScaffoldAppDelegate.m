//
//  ScaffoldAppDelegate.m
//  Milpon
//
//  Created by mootoh on 3/06/09.
//  Copyright deadbeaf.org 2009. All rights reserved.
//

#import "ScaffoldAppDelegate.h"
#import "ScaffoldListViewController.h"
#import "LocalCache.h"

@implementation ScaffoldAppDelegate

@synthesize window;

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [[LocalCache sharedLocalCache] retain];
   }
   return self;
}

- (void)dealloc
{
   [local_cache_ release];
   [slvc release];
   [window release];
   [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   slvc = [[ScaffoldListViewController alloc] initWithStyle:UITableViewStylePlain];
   [window addSubview:slvc.view];
   [window makeKeyAndVisible];
}

@end
