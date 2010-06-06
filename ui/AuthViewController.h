//
//  AuthViewController.h
//  Milpon
//
//  Created by mootoh on 10/22/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMSynchronizer.h"

@interface AuthViewController : UIViewController <UIWebViewDelegate, RTMSynchronizerDelegate>
{
   enum {
      STATE_INITIAL,
      STATE_SUBMITTED,
      STATE_WRONG_PASSWORD,
      STATE_USERINFO_ENTERED,
      STATE_SHOW_WEBVIEW,
      STATE_DONE
   } state;

   IBOutlet UIActivityIndicatorView *authActivity;
   IBOutlet UITextField *usernameField;
   IBOutlet UITextField *passwordField;
   IBOutlet UILabel *instructionLabel;
   IBOutlet UIButton *proceedButton;
   IBOutlet UIWebView *webView;
   
   RTMSynchronizer *syncer;
   NSString *frob;
}

- (IBAction) proceedToAuthorization;
- (IBAction) getToken:(RTMAPI *)api;
- (void) failedInAuthorization;

@end