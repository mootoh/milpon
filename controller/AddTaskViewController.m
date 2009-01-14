//
//  AddTaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "AddTaskViewController.h"
#import "RTMList.h"
#import "AppDelegate.h"
#import "RTMDatabase.h"
#import "ListSelectViewController.h"
#import "RTMTask.h"
#import "RootViewController.h"
#import "UICCalendarPicker.h"
#import "logger.h"

@implementation AddTaskViewController

const float margin_top  = 16.0f;
const float margin_left = 16.0f;
const float column_height = 40.0f;

@synthesize name, list, priority, due_date, note;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
   if (self = [super initWithNibName:nibName bundle:nibBundle]) {
      AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      RTMDatabase *db = app.db;
      lists = [[RTMList allLists:db] retain];

      self.title = @"Add a Task";
      self.priority = @"0";
      self.list = [lists objectAtIndex:0]; // list default: INBOX
   }
   return self;
}

- (void) dealloc
{
   [name_field release];
   [note_field release];
   [priority_segment release];
   [name release];
   [due_date release];
   [lists release];
   [list release];
   [super dealloc];
}

- (void) didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

/* -------------------------------------------------------------------
 * TextFieldDelegate
 */
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
   if (textField == name_field)
      self.name = textField.text;
   else if (textField == note_field)
      self.note = textField.text;
   else
      return YES;

   [textField resignFirstResponder];
   return YES;
}

- (void) updatePriority
{
   self.priority = [NSString stringWithFormat:@"%d", priority_segment.selectedSegmentIndex];
   [self commitTextFields];
}

- (void) close
{
   UIViewController *nav = self.parentViewController;;
   RootViewController *root = (RootViewController *)nav.parentViewController;;
   root.bottomBar.hidden = NO;
   [root reload];
   [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel
{
   [self close];
}

- (void) commitTextFields
{
   [self textFieldShouldReturn:name_field];
   [self textFieldShouldReturn:note_field];
}

/*
 * create RTMTask from given fields
 *
 * TODO:
 *  - how to validate the fields ?
 *  - add note, tag, rrule
 */
- (IBAction) save
{
   [self commitTextFields];

   if (name == nil || [name isEqualToString:@""]) return;

   // store it to the DB
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMDatabase *db = app.db;

   NSArray *keys = [NSArray arrayWithObjects:@"name", @"due", @"list_id", @"priority", @"note", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      name,
      due_date ? due_date : @"",
      list.iD,
      priority,
      note ? note : @"",
      nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [RTMTask createAtOffline:params inDB:db];

   [self close];
}

- (void) loadView
{
   [super loadView];

   /*
    * Navigation buttons
    */
   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   self.navigationItem.leftBarButtonItem = cancelButton;
   [cancelButton release];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
   [submitButton release];

	
   name_field = [[UITextField alloc] initWithFrame:
      CGRectMake(margin_left, margin_top, CGRectGetWidth(self.view.frame)-margin_left, column_height)];
   name_field.placeholder = @"what...";
   name_field.returnKeyType = UIReturnKeyDone;
   name_field.delegate = self;
   [name_field becomeFirstResponder];
   [self.view addSubview:name_field];

   note_field = [[UITextField alloc] initWithFrame:
      CGRectMake(margin_left, margin_top+column_height, CGRectGetWidth(self.view.frame)-margin_left, column_height)];
   note_field.placeholder = @"note...";
   note_field.returnKeyType = UIReturnKeyDone;
   note_field.delegate = self;
   [self.view addSubview:note_field];

   // setup priority segment
   NSArray *priority_items = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
   priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(32, 100, CGRectGetWidth(self.view.frame)-64, 40)];
   for (int i=0; i<priority_items.count; i++)
      [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];

   priority_segment.selectedSegmentIndex = 0;
   [priority_segment addTarget:self action:@selector(updatePriority) forControlEvents:UIControlEventValueChanged];

   [self.view addSubview:priority_segment];

   UICCalendarPicker *picker = [[UICCalendarPicker alloc] initWithFrame:CGRectMake((320.0f-204.0f)/2.0f, 160, 204.0f, 234.0f)];
   [picker setDelegate:self];
   [picker showInView:self.view];
   [picker release];
}

- (void) picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate
{
   LOG(@"picker");
   NSDate *theDate = [selectedDate objectAtIndex:0];

   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
   NSString *ret = [formatter stringFromDate:theDate];
   ret = [ret stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
   ret = [ret stringByAppendingString:@"Z"];
   self.due_date = ret;

   [self.view setNeedsDisplay];
}

- (void) prioritySelected
{
}

@end
