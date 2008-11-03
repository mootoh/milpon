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
	}
	return self;
}

- (void)viewDidLoad {
  self.title = task.name;

	name.text = task.name;
	url.text = task.url;

  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
  [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

  if (task.rrule && ![task.rrule isEqualToString:@""])
     repeat.text = task.rrule;
  
  if (task.due && ![task.due isEqualToString:@""]) {
     NSCalendar *calendar = [NSCalendar currentCalendar];
     unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
     NSDate *due_date = [formatter dateFromString:task.due];
     NSDateComponents *comps = [calendar components:unitFlags fromDate:due_date];    
     
     NSString *dueString = [NSString stringWithFormat:@"%d-%d-%d", [comps year], [comps month], [comps day]];

      due.text = dueString;
  }

  // location.text = [NSString stringWithFormat:@"%d", task.location_id];
   //completed.text = task.completed;
	//priority.text = task.priority;
	postponed.text = [task.postponed stringValue];
	estimate.text = task.estimate;

  for (NSDictionary *note in task.notes) {
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    noteLabel.font = [UIFont systemFontOfSize:10];
    noteLabel.lineBreakMode = UILineBreakModeWordWrap;
    noteLabel.text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];
    [noteView addSubview:noteLabel];
    [noteLabel release];
  }
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
