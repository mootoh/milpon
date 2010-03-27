//
//  RefreshingViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 3/24/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootMenuViewController;

@interface RefreshingViewController : UIViewController
{
   IBOutlet UIActivityIndicatorView *activityIndicatorView;
   IBOutlet UILabel *label;
}

- (IBAction) didRefreshed;

@end