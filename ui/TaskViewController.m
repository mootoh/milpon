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
#import "RTMTask.h"
#import "RTMList.h"
#import "UICCalendarPicker.h"
#import "logger.h"
#import "ListProvider.h"
#import "MilponHelper.h"
#import "AttributeView.h"
#import "DueDateSelectController.h"
#import "NoteEditController.h"
#import "TagSelectController.h"

#define kNOTE_PLACE_HOLDER @"note..."

@implementation DueLabel

- (id) initWithFrame:(CGRect)aRect
{
   if (self = [super initWithFrame:aRect]) {
      toggleCalendarDisplay = NO;
      self.userInteractionEnabled = YES;
   }
   return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   toggleCalendarDisplay = !toggleCalendarDisplay;
   
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

@synthesize task;

// icons {{{
static NSArray *s_icons = nil;

+ (NSArray *) icons
{
   if (! s_icons) {
      NSMutableArray *ics = [[NSMutableArray alloc] init];
      for (int i=1; i<=4; i++) {
         UIImage *img = [[UIImage alloc] initWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
               [NSString stringWithFormat:@"icon_priority_%d.png", i]]];
         [ics addObject:img];
         [img release];
      }
      s_icons = [ics retain];
      [ics release];
   }
   return s_icons;
}
// }}}

enum {
   TAG_NAME = 1,
   TAG_DUE,
   TAG_LIST,
   TAG_TAG,
   TAG_NOTE,
   TAG_INPUT_NAME
};

- (void) viewDidLoad
{
   self.title = task.name;
   [due setViewController:self];

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
   [name_field setDelegate:self asAction:@selector(edit_name)];
   [self.view addSubview:name_field];
   name_field.tag = TAG_NAME;
   [name_field release];

   AttributeView *due_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 60, (320-14*2)/3, 20)];
   [due_field setDelegate:self asAction:@selector(edit_due)];

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
   due_field.tag = TAG_DUE;
   [due_field release];

   AttributeView *list_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 100, (320-14*2)/3, 20)];
   list_field.text = [[ListProvider sharedListProvider] nameForListID:task.list_id];
   list_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease];
   [self.view addSubview:list_field];
   [list_field release];

   AttributeView *tag_field = [[AttributeView alloc] initWithFrame:CGRectMake(14, 140, 320-14*2, 20)];
   tag_field.tag = TAG_TAG;
   //[tag_field setDelegate:self asAction:@selector(edit_tag)];
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

   for (int i=1; i<=4; i++) {
      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((i-1)*44, 0, 44, 44)];
      [btn setImage:[[TaskViewController icons] objectAtIndex:i-1] forState:UIControlStateNormal];
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
   [note_field setDelegate:self asAction:@selector(edit_note)];
   note_field.text = task.name;
   note_field.icon = [[[UIImage alloc] initWithContentsOfFile:
      [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_note.png"]] autorelease];
   note_field.line_width = 1.0f;
   note_field.tag = TAG_NOTE;
   [self.view addSubview:note_field];

   /*
   noteView.font = [UIFont systemFontOfSize:12];
   noteView.delegate = self;
   */

   [notePages addTarget:self action:@selector(displayNote) forControlEvents:UIControlEventTouchUpInside];
   [self displayNote];
   
   
   if (task.url && ![task.url isEqualToString:@""]) {
      UIButton *url_button = [[UIButton alloc] initWithFrame:CGRectMake(280, 100, 20, 20)];
      UIImage *url_image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_url.png"]];
      [url_button setImage:url_image forState:UIControlStateNormal];
      [url_button addTarget:self action:@selector(showWebView) forControlEvents:UIControlEventTouchDown];
      
      [self.view addSubview:url_button];
      [url_image release];
      [url_button release];
   }
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
   [priorityButton setImage:[[TaskViewController icons] objectAtIndex:priority-1] forState:UIControlStateNormal];
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
   [note_field setNeedsDisplay];
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

prioritySelected_N(1);
prioritySelected_N(2);
prioritySelected_N(3);
prioritySelected_N(4);

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   if (textField.tag == TAG_INPUT_NAME) {
      AttributeView *av = (AttributeView *)[self.view viewWithTag:TAG_NAME];
      av.in_editing = NO;
      av.text = textField.text;
      self.task.name = textField.text;
      [av setNeedsDisplay];
   }

   [textField resignFirstResponder];
   [textField removeFromSuperview];
   return YES;
}

- (void) picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate
{
   NSDate *theDate = [selectedDate objectAtIndex:0];
   task.due = theDate;

   [self updateDue];
}

- (void) edit_name
{
   AttributeView *av = (AttributeView *)[self.view viewWithTag:TAG_NAME];
   av.in_editing = YES;
   //[av drawRect:av.frame];

   UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(24, 0, av.frame.size.width-24, av.frame.size.height-av.line_width-2)];
   tf.placeholder = av.text;
   tf.opaque = YES;
   tf.backgroundColor = [UIColor whiteColor];
   tf.font = [UIFont systemFontOfSize:14];
   tf.delegate = self;
   tf.returnKeyType = UIReturnKeyDone;
   tf.tag = TAG_INPUT_NAME;
   [av addSubview:tf];
   [tf becomeFirstResponder];
   [tf release];
}

- (void) edit_due
{
   AttributeView *av = (AttributeView *)[self.view viewWithTag:TAG_DUE];
   av.in_editing = YES;
   [av drawRect:av.frame];

   DueDateSelectController *vc = [[DueDateSelectController alloc] initWithNibName:nil bundle:nil];
   vc.parent = self;
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

- (void) setDue:(NSDate *)date
{
   task.due = date;
   
   NSCalendar *calendar = [NSCalendar currentCalendar];
   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSDateComponents *comps = [calendar components:unitFlags fromDate:task.due];
   
   NSString *dueString = [NSString stringWithFormat:@"%d/%d", [comps month], [comps day]];
   
   AttributeView *av = (AttributeView *)[self.view viewWithTag:TAG_DUE];
   av.in_editing = NO;
   av.text = dueString;
   
   [av setNeedsDisplay];
}

- (void) edit_note
{
   notePages.numberOfPages = task.notes.count;
   if (0 == task.notes.count) {
      return;
   }
   
   NSDictionary *note = [task.notes objectAtIndex:notePages.currentPage];
   NSString *text = [NSString stringWithFormat:@"%@\n%@", [note valueForKey:@"title"], [note valueForKey:@"text"]];

   NoteEditController *vc = [[NoteEditController alloc] initWithNibName:nil bundle:nil];
   vc.parent = self;
   vc.note = text;
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

- (void) edit_tag
{
#if 0
   TagSelectController *vc = [[TagSelectController alloc] initWithNibName:nil bundle:nil];
   vc.parent = self;
   [vc setTags:task.tags];
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
#endif // 0
}

- (void) setList:(RTMList *)list
{
}

- (void) updateView
{
   // TODO
}

- (void) setNote:(NSString *)note
{

   AttributeView *av = (AttributeView *)[self.view viewWithTag:TAG_NOTE];
   av.in_editing = NO;
   av.text = note;
   [av setNeedsDisplay];
}

- (void) showWebView
{
   CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
   UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-44)];
   webView.scalesPageToFit = YES;
   
   UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
   
   NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:task.url]];
   [webView loadRequest:req];
   [vc.view addSubview:webView];
   [self.navigationController pushViewController:vc animated:YES];
   [webView release];
   [vc release];
}

@end
// vim:set fdm=marker:
