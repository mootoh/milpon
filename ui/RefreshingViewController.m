//
//  RefreshingViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/24/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RefreshingViewController.h"
#import "AppDelegate.h"
#import "RTMSynchronizer.h"

@implementation RefreshingViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
//   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshed) name:@"didFetchAll" object:nil];
   [activityIndicatorView startAnimating];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear:(BOOL)animated
{
   AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [super viewWillAppear:animated];
   self.view.alpha = 0.0f;
   [UIView beginAnimations:@"refreshingAnimation" context:nil];
   [UIView setAnimationDelegate:appDelegate];
   [UIView setAnimationDidStopSelector:@selector(refreshingViewAnimation:finished:context:)];
   self.view.alpha = 0.8f;
   self.view.backgroundColor = [UIColor blackColor];
   [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [super dealloc];
}

- (IBAction) didRefreshed
{
   label.text = @"Done";
   [activityIndicatorView stopAnimating];

   [UIView beginAnimations:@"refreshedAnimation" context:nil];
   [UIView setAnimationDuration:0.4f];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(refreshedStop:finished:context:)];
   self.view.alpha = 0.0f;
   [UIView commitAnimations];
}
                                                 
- (void)refreshedStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   //[self dismissModalViewControllerAnimated:NO];
   [self.view removeFromSuperview];
}

@end