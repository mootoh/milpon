//
//  UpgradeFetchAllViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 5/16/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "UpgradeFetchAllViewController.h"
#import "AppDelegate.h"

@implementation UpgradeFetchAllViewController

- (void) dealloc
{
    [super dealloc];
}

- (void) loadView
{
   [super loadView];

   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   UILabel *upgradingLabel = [[UILabel alloc] initWithFrame:CGRectMake(appFrame.origin.x + 48, appFrame.size.height/2, appFrame.size.width-48, 64)];
   upgradingLabel.numberOfLines = 2;
   upgradingLabel.text = @"upgrading the database and\nrefresh all data from RTM site...";
   [self.view addSubview:upgradingLabel];
}

- (void) done:(NSTimer*)theTimer
{
   [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];

   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitForFetch) name:@"waitForFetch" object:nil];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchAll" object:nil];
}

- (void) waitForFetch
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"waitForFetch" object:nil];
   
   NSTimer *timer;
   timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(done:) userInfo:nil repeats:NO];
}   
@end