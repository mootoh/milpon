//
//  TaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "TaskViewController.h"
#import "LocalCache.h"
#import "AppDelegate.h"
#import "RTMList.h"
#import "UICCalendarPicker.h"
#import "logger.h"
#import "ListProvider.h"
#import "MilponHelper.h"

#define kNOTE_PLACE_HOLDER @"note..."

@implementation DueLabel
- (id) initWithFrame:(CGRect)aRect
{
   if (self = [super initWithFrame:aRect]) {
      toggleCalendarDisplay = NO;
   }
   return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   toggleCalendarDisplay = toggleCalendarDisplay ? NO : YES;
   if (toggleCalendarDisplay) {
			UICCalendarPicker *picker = [[UICCalendarPicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 204.0f, 234.0f)];
      [picker setDelegate:viewController];
      [picker showInView:self.superview];
      [picker release];
   }
}

- (void) dealloc
{
   [viewController release];
   [super dealloc];
}

- (void) setViewController:(UIViewController *)vc
{
   viewController = vc;
   [vc retain];
}

@end


@interface TaskViewController (Private)
- (void) setPriorityButton;
- (void) displayNote;
@end


@implementation TaskViewController

// icons {{{
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
      s_icons = [ics retain];
      [ics release];
      first = NO;
   }
   return s_icons;
}
// }}}

@synthesize task;

- (void) viewDidLoad
{
   self.title = task.name;
   [due setViewController:self];
   due.userInteractionEnabled = YES;

   name.text = task.name;
   name.clearsOnBeginEditing = NO;
   name.delegate = self;
   url.text = task.url;

   list.text = [[ListProvider sharedListProvider] nameForListID:task.list_id];

   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

   if (task.rrule && ![task.rrule isEqualToString:@""])
      repeat.text = task.rrule;

   [self updateDue];

   // location.text = [NSString stringWithFormat:@"%d", task.location_id];
   //completed.text = task.completed;

   [self setPriorityButton];
   [priorityButton addTarget:self action:@selector(togglePriorityView) forControlEvents:UIControlEventTouchDown];

   NSMutableArray *btns = [[NSMutableArray alloc] init];

   dialogView = [[UIView alloc] initWithFrame:
      CGRectMake(priorityButton.frame.origin.x, priorityButton.frame.origin.y+24, 44*4, 44)];
   dialogView.backgroundColor = [UIColor colorWithRed:51.0f/256.0f green:51.0f/256.0f blue:51.0f/256.0f alpha:0.9f];
   dialogView.opaque = NO;
   dialogView.hidden = YES;

   for (int i=0; i<4; i++) {
      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*44, 0, 44, 44)];
      [btn setImage:[[TaskViewController icons] objectAtIndex:i] forState:UIControlStateNormal];
      NSString *selector = [NSString stringWithFormat:@"prioritySelected_%d", i];
      [btn addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventTouchDown];
      btn.opaque = NO;
      [dialogView addSubview:btn];
      [btns addObject:btn];

      [btn release];
   }

   prioritySelections = btns;
   [self.view addSubview:dialogView];

   postponed.text = [task.postponed stringValue];
   postponed.delegate = self;
   estimate.text = task.estimate;
   estimate.delegate = self;

   noteView.font = [UIFont systemFontOfSize:12];
   noteView.delegate = self;

   [notePages addTarget:self action:@selector(displayNote) forControlEvents:UIControlEventTouchUpInside];
   [self displayNote];
}

- (void) updateDue
{
   if (task.due && task.due != [MilponHelper sharedHelper].invalidDate) {
      NSCalendar *calendar = [NSCalendar currentCalendar];
      unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
      NSDateComponents *comps = [calendar components:unitFlags fromDate:task.due];

      NSString *dueString = [NSString stringWithFormat:@"%d/%d", [comps month], [comps day]];

      due.text = dueString;
   }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void) dealloc
{
   if (task) [task release];
   [dialogView release];
   [prioritySelections release];
   [super dealloc];
}

- (void) setPriorityButton
{
   int priority = [task.priority intValue];

   [priorityButton setImage:[[TaskViewController icons] objectAtIndex:priority] forState:UIControlStateNormal];
}

- (void) displayNote
{
   notePages.numberOfPages = task.notes.count;
   if (0 == task.notes.count) {
      noteView.text = kNOTE_PLACE_HOLDER;
      return;
   }

   NSDictionary *note = [task.notes objectAtIndex:notePages.currentPage];
   NSString *text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];
   noteView.text = text;
}

- (void) togglePriorityView
{
   dialogView.hidden = ! dialogView.hidden;
   [dialogView setNeedsDisplay];

}

#define prioritySelected_N(n) \
- (void) prioritySelected_##n \
{ \
   task.priority = [NSNumber numberWithInt:n]; \
   [self setPriorityButton]; \
   [self togglePriorityView]; \
}

prioritySelected_N(0);
prioritySelected_N(1);
prioritySelected_N(2);
prioritySelected_N(3);

/* -------------------------------------------------------------------
 * UITextFieldDelegate
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   LOG(@"textFieldShouldReturn");
   if (textField == name) {
   } else if (textField == location) {
   } else if (textField == repeat) {
   } else if (textField == estimate) {
   } else if (textField == list) {
   }

   [textField resignFirstResponder];
   return YES;
}

/* -------------------------------------------------------------------
 * UITextViewDelegate
 */

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   if ([textView.text isEqualToString:kNOTE_PLACE_HOLDER])
      textView.text = @"";
   return YES;
}

// TODO: #27
#if 0
- (void)textViewDidEndEditing:(UITextView *)textView
{
   if ([textView.text isEqualToString:kNOTE_PLACE_HOLDER])
      return;

   if ([task isKindOfClass:[RTMPendingTask class]]) {
      // TODO
      return;
   }

   if (0 == task.notes.count) { // create one
      [RTMPendingTask createNote:textView.text withID:((RTMExistingTask *)task).task_series_id inDB:db];
      return;
   }

   NSInteger page = notePages.currentPage;

   NSDictionary *note = [task.notes objectAtIndex:notePages.currentPage];
   NSString *text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];
   noteView.text = text;
}
#endif // 0

- (void) picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate
{
   LOG(@"picker");
   NSDate *theDate = [selectedDate objectAtIndex:0];
   task.due = theDate;

   [self updateDue];
}


@end
// vim:set fdm=marker:
