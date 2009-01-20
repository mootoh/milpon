//
//  TrialAppDelegate.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrialAppDelegate : NSObject <UIApplicationDelegate> {
   IBOutlet UIWindow *window;
   IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

@end
