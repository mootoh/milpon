//
//  ProgressView.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

static const float messageLabelPadding = 18.0f;

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      inProgress = NO;
      self.opaque = NO;

      activityIndicator = [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      activityIndicator.frame = CGRectMake(0, frame.size.height/2-16/2, 16, 16);
      activityIndicator.hidesWhenStopped = YES;
      [self addSubview:activityIndicator];

      messageRect = CGRectMake(messageLabelPadding, 0,
         frame.size.width-messageLabelPadding, frame.size.height/2);

      messageLabel = [[UILabel alloc] initWithFrame:messageRect];
      messageLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.0f];
      messageLabel.opaque = NO;
      messageLabel.font = [UIFont systemFontOfSize:10];
      messageLabel.textColor = [UIColor whiteColor];
      messageLabel.textAlignment = UITextAlignmentCenter;
      messageLabel.text = @"message";
      [self addSubview:messageLabel];

      progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
      progressView.frame = CGRectMake(messageLabelPadding, frame.size.height/2+2,
         frame.size.width-messageLabelPadding, frame.size.height/2);
      progressView.hidden = YES;
      [self addSubview:progressView];
   }
   return self;
}

- (void)dealloc
{
   [progressView release];
   [messageLabel release];
   [activityIndicator release];
   [message release];
   [super dealloc];
}

- (void) progressBegin
{
   [self toggleDisplay];
   [activityIndicator startAnimating];
   progressView.progress = 0.0;
}

- (void) progressEnd
{
   [self toggleDisplay];
   [activityIndicator stopAnimating];
   progressView.progress = 1.0;
}

- (void) updateMessage:(NSString *)msg
{
   messageLabel.text = msg;
}

- (void) updateMessage:(NSString *)msg withProgress:(float)pg
{
   [self performSelectorOnMainThread:@selector(updateMessage:) withObject:msg waitUntilDone:YES];
   [self performSelectorInBackground:@selector(updateProgress:)
                          withObject:[NSNumber numberWithFloat:pg]];
}

- (void) updateProgress:(NSNumber *) pg
{
   progressView.progress = [pg floatValue];
}

- (void) setMessage:(NSString *)msg
{
   if (message) [message release];
   message = [msg retain];

   if (! inProgress) {
      messageLabel.text = msg;
      [messageLabel setNeedsDisplay];
   }
}

- (NSString *)message
{
   return message;
}

- (void) toggleDisplay
{
   inProgress = ! inProgress;

   if (inProgress) {
      progressView.hidden = NO;
      [progressView setNeedsDisplay];
      //messageLabel.center = self.center;
   } else {
      progressView.hidden = YES;
      [progressView setNeedsDisplay];
      //messageLabel.frame = messageRect;
   }
}

@end
