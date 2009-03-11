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
#import "AttributeView.h"

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

/*
   name.text = task.name;
   name.clearsOnBeginEditing = NO;
   name.delegate = self;
*/

   AttributeView *name_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 20, 320-14*2, 20)];
   name_field.text = task.name;
   name_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_target.png"]] autorelease];
   name_field.line_width = 2.0f;
   [self.view addSubview:name_field];
   [name_field release];

   AttributeView *due_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 60, (320-14*2)/3, 20)];

   if (task.due) {
      NSCalendar *calendar = [NSCalendar currentCalendar];
      unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
      NSDateComponents *comps = [calendar components:unitFlags fromDate:task.due];

      NSString *dueString = [NSString stringWithFormat:@"%d/%d", [comps month], [comps day]];

      due_field.text = dueString;
   }
   due_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]] autorelease];
   [self.view addSubview:due_field];
   [due_field release];

   AttributeView *list_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 100, (320-14*2)/3, 20)];
   list_field.text = [[ListProvider sharedListProvider] nameForListID:task.list_id];
   list_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease];
   [self.view addSubview:list_field];
   [list_field release];

   AttributeView *tag_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 140, 320-14*2, 20)];
   NSString *tag_str = @"";
   for (NSString *tag in task.tags)
      tag_str = [tag_str stringByAppendingFormat:@"%@ ", tag];
   tag_field.text = tag_str;
   
   tag_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease];
   [self.view addSubview:tag_field];
   [tag_field release];

   [self updateDue];

   [self setPriorityButton];
   [priorityButton addTarget:self action:@selector(togglePriorityView) forControlEvents:UIControlEventTouchDown];

   NSMutableArray *btns = [[NSMutableArray alloc] init];

   dialogView = [[UIView alloc] initWithFrame:
      CGRectMake(priorityButton.frame.origin.x-44*3, priorityButton.frame.origin.y+24, 44*4, 44)];
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

   note_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 180, 320-14*2, 150)];
   note_field.text = task.name;
   note_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_note.png"]] autorelease];
   note_field.line_width = 1.0f;
   [self.view addSubview:note_field];

   /*
   noteView.font = [UIFont systemFontOfSize:12];
   noteView.delegate = self;
   */

   [notePages addTarget:self action:@selector(displayNote) forControlEvents:UIControlEventTouchUpInside];
   [self displayNote];
}

- (void) updateDue
{
   if (task.due) {
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
   [due release];
   [task release];
   [note_field release];
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
      note_field.text = kNOTE_PLACE_HOLDER;
      return;
   }

   NSDictionary *note = [task.notes objectAtIndex:notePages.currentPage];
   NSString *text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];
   note_field.text = text;
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
#if 0
   LOG(@"textFieldShouldReturn");
   if (textField == name) {
   } else if (textField == location) {
   } else if (textField == repeat) {
   } else if (textField == estimate) {
   } else if (textField == list) {
   }

   [textField resignFirstResponder];
#endif // 0
   return YES;
}

- (void) picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate
{
   LOG(@"picker");
   NSDate *theDate = [selectedDate objectAtIndex:0];
   task.due = theDate;

   [self updateDue];
}

@end
// vim:set fdm=marker:
