//
//  ProgressViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 11/19/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressView;

@interface ProgressViewController : UIViewController
{
   ProgressView *pv;
   UIButton *btn;
}

- (IBAction) progress;

@end
