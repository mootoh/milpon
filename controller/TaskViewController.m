//
//  TaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "TaskViewController.h"


@implementation TaskViewController

@synthesize task;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

- (void)viewDidLoad {
  self.title = task.name;

	name.text = task.name;
	url.text = task.url;


  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
  [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss zzz"];
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
  NSDate *due_date = [formatter dateFromString:task.due];
  NSDateComponents *comps = [calendar components:unitFlags fromDate:due_date];    
  
  NSString *dueString = [NSString stringWithFormat:@"%d-%d-%d", [comps year], [comps month], [comps day]];

	due.text = dueString;
	location.text = [NSString stringWithFormat:@"%d", task.location];
	//completed.text = task.completed;
	//priority.text = task.priority;
	postponed.text = [NSString stringWithFormat:@"%d", task.postponed];
	estimate.text = task.estimate;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
