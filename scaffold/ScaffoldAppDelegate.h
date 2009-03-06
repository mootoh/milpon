//
//  ScaffoldAppDelegate.h
//  Milpon
//
//  Created by mootoh on 3/06/09.
//  Copyright deadbeaf.org 2009. All rights reserved.
//

@class ScaffoldListViewController;
@class LocalCache;

@interface ScaffoldAppDelegate : NSObject <UIApplicationDelegate>
{	
   LocalCache *local_cache_;

   IBOutlet UIWindow *window;
   IBOutlet ScaffoldListViewController *slvc;
   IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) UIWindow *window;

@end
