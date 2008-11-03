//
//  RootViewController.h
//  Milpon
//
//  Created by mootoh on 10/17/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressView;

@interface RootViewController : UIViewController
{
   IBOutlet UINavigationController *navigationController;
   UIToolbar *bottomBar;
   ProgressView *progressView;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIToolbar *bottomBar;
@property (nonatomic, retain) ProgressView *progressView;

- (IBAction) addTask;
- (IBAction) upload;
- (void) fetchAll;

@end
