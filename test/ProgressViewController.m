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

   pv = [[ProgressView alloc] initWithFrame:CGRectMake(32,48, 200,80)];
   [self.view addSubview:pv];

   UIButton *ptbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   [self.view addSubview:ptbtn];
   ptbtn.frame = CGRectMake(320/2-160/2, 200, 160, 40);
   [ptbtn addTarget:self action:@selector(progress) forControlEvents:UIControlEventTouchDown];
   [ptbtn setTitle:@"trigger progress" forState:UIControlStateNormal];

   UIButton *msbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   [self.view addSubview:msbtn];
   msbtn.frame = CGRectMake(320/2-160/2, 260, 160, 40);
   [msbtn addTarget:self action:@selector(setMessage) forControlEvents:UIControlEventTouchDown];
   [msbtn setTitle:@"show message" forState:UIControlStateNormal];
}

- (void)dealloc
{
   [pv release];
   [super dealloc];
}

- (IBAction) progress
{
   [self performSelectorInBackground:@selector(progressInBackground) withObject:nil];
}

- (void) progressInBackground
{
   [pv progressBegin];
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

@end
