//
//  ProgressView.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ProgressView.h"


@implementation ProgressView

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      inProgress = NO;
      self.opaque = NO;

      activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      activity.frame = CGRectMake(frame.origin.x, frame.origin.y, 16, 16);
      activity.hidesWhenStopped = YES;
      [self addSubview:activity];

      messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-128/2, 0, 128, 20)];
      messageLabel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.0];
      messageLabel.opaque = YES;
      messageLabel.font = [UIFont systemFontOfSize:10];
      messageLabel.textColor = [UIColor whiteColor];
      messageLabel.textAlignment = UITextAlignmentCenter;
      [self addSubview:messageLabel];

      progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
      progress.frame = CGRectMake(frame.size.width/2-128/2, frame.size.height-10, 128, 6);
      progress.hidden = NO;
      [self addSubview:progress];
   }
   return self;
}

- (void)drawRect:(CGRect)rect
{
   [super drawRect:rect];
   if (inProgress) {
      [activity startAnimating];
   } else {
      [activity stopAnimating];
   }
}

- (void)dealloc
{
   [progress release];
   [messageLabel release];
   //[activity release];
   [message release];
   [super dealloc];
}

- (void) progressBegin
{
   inProgress = YES;
   progress.hidden = NO;
   progress.progress = 0.0;
}

- (void) progressEnd
{
   inProgress = NO;
   progress.hidden = NO;
   progress.progress = 1.0;
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
   progress.progress = [pg floatValue];
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

@end
