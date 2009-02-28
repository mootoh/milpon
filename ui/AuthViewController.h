//
//  AuthViewController.h
//  Milpon
//
//  Created by mootoh on 10/22/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AuthViewController : UIViewController
{
   enum {
      STATE_INITIAL,
      STATE_JUMPED,
      STATE_DONE
   } state;

   UILabel *greetingLabel;
   UILabel *instructionLabel;
   UIActivityIndicatorView *authActivity;
   UIButton *confirmButton;
   UIToolbar *bottomBar;

   RootViewController *rootViewController;
}

@property (nonatomic, retain) UIToolbar *bottomBar;
@property (nonatomic, retain) RootViewController *rootViewController;

- (IBAction) auth;
- (IBAction) getToken;
- (void) greet;

@end
// vim:set ft=objc:
