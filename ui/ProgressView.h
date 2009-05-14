//
//  ProgressView.h
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

enum {
   PROGRESSVIEW_TAG = 1
};

@interface ProgressView : UIView
{
  UIActivityIndicatorView *activityIndicator;
  UILabel *messageLabel;
  UIProgressView *progressView;
  NSString *message;
  BOOL inProgress;
  CGRect messageRect;
}

@property (nonatomic,retain) NSString *message;

- (void) progressBegin;
- (void) progressEnd;
- (void) updateMessage:(NSString *)msg;

/**
 * @note should be called in background thread (not main thread)
 */
- (void) updateMessage:(NSString *)msg withProgress:(float)pg;
- (void) toggleDisplay;

@end
