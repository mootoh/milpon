//
//  MPAppDelegate.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPAppDelegate : NSObject <UIApplicationDelegate>
{
   IBOutlet UIWindow *window;
   IBOutlet UINavigationController *navigationController;
}

@end