//
//  TrialNoteEditController.m
//  Milpon
//
//  Created by mootoh on 1/23/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TrialNoteEditController.h"
#import "TrialAddTaskViewController.h"

@implementation TrialNoteEditController

@synthesize parent;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
       self.title = @"Note";
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
   [note_view becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
   self.parent.note = note_view.text;
   [self.parent.theTableView reloadData];
   [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end