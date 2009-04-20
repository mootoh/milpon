//
//  TrialNoteEditController.m
//  Milpon
//
//  Created by mootoh on 1/23/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "NoteEditController.h"
#import "AddTaskViewController.h"

@implementation NoteEditController

@synthesize parent, note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
       self.title = @"Note";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   [super viewDidLoad];
   //note_view.text = note;
   [note_view becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self.parent setNote:note_view.text];
   [self.parent updateView];
   [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
   [super dealloc];
}

@end