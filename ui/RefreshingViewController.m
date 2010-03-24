//
//  RefreshingViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/24/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RefreshingViewController.h"
#import "RootMenuViewController.h"

@implementation RefreshingViewController
@synthesize rootMenuViewController;

- (void)viewDidLoad
{
   [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshed) name:@"didFetchAll" object:nil];
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
   self.view.alpha = 0.0f;
   [UIView beginAnimations:@"refreshingAnimation" context:nil];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(refreshingStop:finished:context:)];
   self.view.alpha = 0.8f;
   self.view.backgroundColor = [UIColor blackColor];
   [UIView commitAnimations];
}

- (void)refreshingStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   [rootMenuViewController fetchAll];   
}

- (void) viewDidAppear:(BOOL)animated
{
}

- (void) viewWillDisappear:(BOOL)animated
{
}

- (void) viewDidDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
   [self dismissModalViewControllerAnimated:NO];
}

@end