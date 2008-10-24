//
//  ProgressView.h
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView {
  UIActivityIndicatorView *activity;
  UILabel *messageLabel;
  UIProgressView *progress;
  NSString *message;
}

@property (nonatomic,retain) NSString *message;

- (void) progressBegin;
- (void) progressEnd;
- (void) updateMessage:(NSString *)msg;
- (void) updateMessage:(NSString *)msg withProgress:(float)pg;

@end
