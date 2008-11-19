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

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView
{
   [super loadView];
   self.view.backgroundColor = [UIColor grayColor];

   pv = [[ProgressView alloc] initWithFrame:CGRectMake(32,48, 200,100)];
   [self.view addSubview:pv];

   progressTriggerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   [self.view addSubview:progressTriggerButton];
   progressTriggerButton.frame = CGRectMake(320/2-80/2, 200, 80, 40);
   [progressTriggerButton addTarget:self action:@selector(progress) forControlEvents:UIControlEventTouchDown];

   messageSetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   [self.view addSubview:messageSetButton];
   messageSetButton.frame = CGRectMake(320/2-80/2, 260, 80, 40);
   [messageSetButton addTarget:self action:@selector(setMessage) forControlEvents:UIControlEventTouchDown];

}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
   [messageSetButton release];
   [progressTriggerButton release];
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

   float pg = 0.0;
   for (int i=0; i<10; i++) {
      [pv updateMessage:[NSString stringWithFormat:@"progress... %f", pg] withProgress:pg];
      pg += 0.1;
      usleep(100000);
   }
   [pv progressEnd];
}


- (IBAction) setMessage
{
   pv.message = @"message set from controller.";
}

@end
