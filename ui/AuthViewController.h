//
//  AuthViewController.h
//  Milpon
//
//  Created by mootoh on 10/22/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AuthWebViewController;

@interface AuthViewController : UIViewController
{
   enum {
      STATE_INITIAL,
      STATE_JUMPED,
      STATE_DONE
   } state;

   IBOutlet UIActivityIndicatorView *authActivity;
   IBOutlet UITextField *usernameField;
   IBOutlet UITextField *passwordField;
   IBOutlet UILabel *instructionLabel;
   IBOutlet UIButton *proceedButton;

   AuthWebViewController *authWebViewController;
}

- (IBAction) proceedToAuthorization;
- (IBAction) getToken;

@end
// vim:set ft=objc:
