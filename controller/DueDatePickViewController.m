//
//  DueDatePickViewController.m
//  Milpon
//
//  Created by mootoh on 10/18/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "DueDatePickViewController.h"
#import "AddTaskViewController.h"

@implementation DueDatePickViewController

@synthesize parent;

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
- (void)loadView {
   [super loadView];

   CGRect screenRect = [[UIScreen mainScreen] applicationFrame];

   picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, screenRect.size.height/4, screenRect.size.width, screenRect.size.height/2)];
   picker.datePickerMode = UIDatePickerModeDate;
   [self.view addSubview:picker];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
[super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)dealloc {
   [picker release];
   [super dealloc];
}

// pass due date to parent.
- (IBAction) save {
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
   NSString *ret = [formatter stringFromDate:picker.date];
   ret = [ret stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
   ret = [ret stringByAppendingString:@"Z"];
   parent.due_date = ret;
   [self.parent.tableView reloadData];
   [self.navigationController popViewControllerAnimated:YES];
}

@end
