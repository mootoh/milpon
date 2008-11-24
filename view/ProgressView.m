//
//  ProgressView.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

static const float messageLabelPadding = 16.0f;

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      inProgress = NO;
      self.opaque = NO;

      activityIndicator = [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      activityIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, 16, 16);
      activityIndicator.hidesWhenStopped = YES;
      [self addSubview:activityIndicator];

      messageRect = CGRectMake(frame.origin.x+messageLabelPadding, frame.origin.y, frame.size.width-messageLabelPadding*2, 20);

      messageLabel = [[UILabel alloc] initWithFrame:messageRect];
      messageLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.0f];
      messageLabel.opaque = YES;
      messageLabel.font = [UIFont systemFontOfSize:10];
      messageLabel.textColor = [UIColor whiteColor];
      messageLabel.textAlignment = UITextAlignmentCenter;
      messageLabel.text = @"message";
      [self addSubview:messageLabel];

      progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
      progressView.frame = CGRectMake(frame.size.width/2-128/2, frame.size.height-10, 128, 6);
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
   //[self toggleDisplay];
   [activityIndicator startAnimating];
   progressView.progress = 0.0;
}

- (void) progressEnd
{
   //[self toggleDisplay];
   [activityIndicator stopAnimating];
   progressView.progress = 1.0;
}

- (void) updateMessage:(NSString *)msg
{
   messageLabel.text = msg;
}

- (void) updateMessage:(NSString *)msg withProgress:(float)pg
{
   messageLabel.text = msg;

   [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:pg]];
}

- (void) updateProgress:(NSNumber *)pg
{
   progressView.progress = [pg floatValue];
   //[progressView setNeedsDisplay];
   [messageLabel setNeedsDisplay];
}

- (void) setMessage:(NSString *)msg
{
   if (message) [message release];
   message = [msg retain];

   if (! inProgress) {
      messageLabel.text = msg;
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
      messageLabel.center = self.center;
   } else {
      //progressView.hidden = YES;
      messageLabel.frame = messageRect;
   }
}

@end
