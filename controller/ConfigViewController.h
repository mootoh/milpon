//
//  ConfigViewController.h
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ConfigViewController : UITableViewController
{
   enum {
      CONFIG_RELOAD,
      CONFIG_FEEDBACK,
      CONFIG_VERSION,
      CONFIG_COUNT
   } types;

   RootViewController *rootViewController;
   UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) RootViewController *rootViewController;

@end
