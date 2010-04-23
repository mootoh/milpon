//
//  RootViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"

@implementation RootViewController


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void) setupToolbar
{
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:app action:@selector(update)];
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(addTask)];
   
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   UIBarButtonItem *tightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   tightSpace.width = 20.0f;
   
   UIBarButtonItem *overviewButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_overview_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToOverview)];
   UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToList)];
   UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_tag_disabled.png"] style:UIBarButtonItemStylePlain target:app action:@selector(switchToTag)];
   
   self.toolbarItems = [NSArray arrayWithObjects:refreshButton, flexibleSpace, overviewButton, tightSpace, listButton, tightSpace, tagButton, flexibleSpace, addButton, nil];
   self.navigationController.toolbar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
   [self.navigationController setToolbarHidden:NO];
   [addButton release];
   [listButton release];
   [tagButton release];
   [overviewButton release];
   [tightSpace release];
   [flexibleSpace release];
   [refreshButton release];   
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self setupToolbar];
}

- (void) viewWillDisappear:(BOOL)animated
{
   [super viewWillAppear:animated];
   self.navigationItem.rightBarButtonItem = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"info" style:UIBarButtonItemStylePlain target:app action:@selector(showInfo)];
   self.navigationItem.rightBarButtonItem = infoButton;
   [infoButton release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [super dealloc];
}

#pragma mark Others

- (void) reloadFromDB
{
}

@end