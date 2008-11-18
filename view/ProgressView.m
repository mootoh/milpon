//
//  ProgressView.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ProgressView.h"


@implementation ProgressView

@synthesize message;

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.opaque = NO;
    //activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //activity.frame = CGRectMake(4, 0, 16, 16);
    //activity.hidesWhenStopped = YES;
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-128/2, 0, 128, 20)];
    messageLabel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.0];
    messageLabel.opaque = YES;
    messageLabel.font = [UIFont systemFontOfSize:10];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = UITextAlignmentCenter;

    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.frame = CGRectMake(frame.size.width/2-128/2, frame.size.height-10, 128, 6);
    progress.hidden = NO;

    //[self addSubview:activity];
    [self addSubview:messageLabel];
    [self addSubview:progress];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  //[activity startAnimating];
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
  progress.hidden = NO;
  progress.progress = 0.0;
}

- (void) progressEnd
{
  progress.hidden = NO;
  progress.progress = 1.0;
}

- (void) updateMessage:(NSString *)msg
{
  messageLabel.text = msg;
  [messageLabel setNeedsDisplay];
}

- (void) updateMessage:(NSString *)msg withProgress:(float)pg
{
  messageLabel.text = msg;
  [messageLabel setNeedsDisplay];
  [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:pg]];
}

- (void) updateProgress:(NSNumber *)pg
{
  progress.progress = [pg floatValue];
}

@end
