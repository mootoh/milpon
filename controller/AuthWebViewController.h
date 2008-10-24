//
//  AuthWebViewController.h
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthWebViewController : UIViewController <UIWebViewDelegate> {
  NSURL *url;
}

@property (nonatomic, retain) NSURL *url;

@end
