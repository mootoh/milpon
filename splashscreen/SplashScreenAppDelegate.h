//
//  SplashScreenAppDelegate.h
//  Milpon
//
//  Created by Motohiro Takayama on 5/17/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@interface SplashScreenAppDelegate : NSObject
{
   IBOutlet UIWindow *window;
   IBOutlet UIViewController *splashScreenViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIViewController *splashScreenViewController;

@end
