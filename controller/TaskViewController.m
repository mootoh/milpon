//
//  TaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "TaskViewController.h"
#import "RTMDatabase.h"
#import "AppDelegate.h"
#import "RTMList.h"
#import "logger.h"

@interface TaskViewController (Private)
- (void) setPriorityButton;
@end


@implementation TaskViewController

static NSArray *s_icons;

+ (NSArray *) icons
{
   static BOOL first = YES;
   if (first) {
      NSMutableArray *ics = [[NSMutableArray alloc] init];
      for (int i=0; i<4; i++) {
         UIImage *img = [[UIImage alloc] initWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
               [NSString stringWithFormat:@"icon_priority_%d.png", i]]];
         [ics addObject:img];
         [img release];
      }
      s_icons = ics;
   }
   return s_icons;
}



@synthesize task;

- (void) viewDidLoad
{
   self.title = task.name;

   name.text = task.name;
   name.clearsOnBeginEditing = NO;
   url.text = task.url;

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMDatabase *db = app.db;

   list.text = [RTMList nameForListID:task.list_id fromDB:db];

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

   [self setPriorityButton];

   dialogView = [[UIView alloc] initWithFrame:
      CGRectMake(priorityButton.frame.origin.x, priorityButton.frame.origin.y+24, 44*4, 44)];
   dialogView.backgroundColor = [UIColor blackColor];
   dialogView.hidden = YES;

   for (int i=0; i<4; i++) {
      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*44, 0, 44, 44)];
      [btn setImage:[[TaskViewController icons] objectAtIndex:i] forState:UIControlStateNormal];
      [btn addTarget:self action:@selector(togglePriorityView) forControlEvents:UIControlEventTouchDown];
      [dialogView addSubview:btn];
      [btn release];
   }

   [self.view addSubview:dialogView];

   postponed.text = [task.postponed stringValue];
   estimate.text = task.estimate;

   CGRect note_view_frame = noteView.frame;
   NSArray *notes = task.notes;
   int i=0;
   for (NSDictionary *note in notes) {
      int height = note_view_frame.size.height / notes.count;
      UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height*i, note_view_frame.size.width, height)];
      noteLabel.font = [UIFont systemFontOfSize:10];
      noteLabel.lineBreakMode = UILineBreakModeCharacterWrap;
      noteLabel.text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];
      noteLabel.textAlignment = UITextAlignmentLeft;
      noteLabel.numberOfLines = 2;
      [noteView addSubview:noteLabel];
      [noteLabel release];
      i++;
   }
}


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
   if (task) [task release];
   [dialogView release];
   [super dealloc];
}

- (void) setPriorityButton
{
   int priority = [task.priority intValue];
   UIImage *priorityImage = [[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
         [NSString stringWithFormat:@"icon_priority_%d.png", priority]]];

   [priorityButton setImage:priorityImage forState:UIControlStateNormal];
   [priorityButton addTarget:self action:@selector(togglePriorityView) forControlEvents:UIControlEventTouchDown];

   [priorityImage release];
}

- (void) togglePriorityView
{
   dialogView.hidden = ! dialogView.hidden;
   [dialogView setNeedsDisplay];

   // selected button action
}

@end
