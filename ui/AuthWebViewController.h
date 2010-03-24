//
//  AuthWebViewController.h
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthWebViewController : UIViewController <UIWebViewDelegate>
{
   UIWebView *webView_;
   NSURL *url;
   NSString *username;
   NSString *password;
   NSInteger state;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (void) startLoading;
- (void) stop;

@end
