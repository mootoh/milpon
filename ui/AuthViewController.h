//
//  AuthViewController.h
//  Milpon
//
//  Created by mootoh on 10/22/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

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
}

@property (nonatomic, retain) UIToolbar *bottomBar;

- (IBAction) auth;
- (IBAction) getToken;
- (void) greet;

@end
// vim:set ft=objc:
