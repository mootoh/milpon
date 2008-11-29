//
//  ProgressViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 11/19/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ProgressViewController.h"
#import "ProgressView.h"

@implementation ProgressViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView
{
   [super loadView];
   self.view.backgroundColor = [UIColor grayColor];

   const int button_width = 80;
   const int button_height = 32;

   NSArray *titles = [NSArray arrayWithObjects:
      @"progressBegin", @"progressEnd",
      @"updateMessage", @"updateMessage:withProgress",
      @"toggleDisplay",
      @"progress", @"setMessage", @"updateProgress", nil];

   SEL actions[] = {
      @selector(progressBegin), @selector(progressEnd),
      @selector(updateMessage), @selector(updateMessageWithProgress),
      @selector(toggleDisplay),
      @selector(progress), @selector(setMessage), @selector(updateProgress)};

   const int button_count = titles.count;

   for (int i=0; i<button_count; i++) {
      UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      btn.frame = CGRectMake(16, 16+button_height*i + 16, button_width, button_height);
      btn.font = [UIFont systemFontOfSize:10];
      [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];

      [btn addTarget:self action:actions[i] forControlEvents:UIControlEventTouchDown];
      [self.view addSubview:btn];
   }

   pv = [[ProgressView alloc] initWithFrame:CGRectMake(32,320, 180,40)];
   [self.view addSubview:pv];
}

- (void)dealloc
{
   [pv release];
   [super dealloc];
}

- (IBAction) progress
{
   [pv progressBegin];
   [self performSelectorInBackground:@selector(progressInBackground) withObject:nil];
}

- (void) progressInBackground
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   float pg = 0.0;
   for (int i=0; i<10; i++) {
      [pv updateMessage:[NSString stringWithFormat:@"progress... %f", pg] withProgress:pg];
      pg += 0.1;
      usleep(100000);
   }

   [pool release];
   [pv progressEnd];
}

- (IBAction) setMessage
{
   static int count = 1;
   if (count % 2)
      [pv progressBegin];
   else
      [pv progressEnd];

   pv.message = [NSString stringWithFormat:@"message set from controller %d", count++];
}

- (void) progressBegin
{
   [pv progressBegin];
}

- (void) progressEnd
{
   [pv progressEnd];
}

- (void) updateMessage
{
   [pv updateMessage:@"update the message"];
}

- (void) updateMessageWithProgress
{
   [pv updateMessage:@"with progress" withProgress:0.5];
}

- (void) toggleDisplay
{
   [pv toggleDisplay];
}

- (void) updateProgress
{
   static float pg = 0.0f;
   [pv updateProgress:[NSNumber numberWithFloat:pg]];
   pg += 0.1f;
}

@end
