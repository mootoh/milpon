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

enum {
   TEXTFIELD_NAME,
   TEXTFIELD_NOTE
};

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

#if 0
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   switch ([indexPath row]) {
      case CELL_NAME:
         [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
         break;
      case CELL_LIST: {
         ListSelectViewController *ctr = [[[ListSelectViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
         ctr.parent = self;

         [self textFieldShouldReturn:name_field];
         [self textFieldShouldReturn:note_field];
         [[self navigationController] pushViewController:ctr animated:YES];
         break;
       }
      case CELL_PRIORITY_DUE: {
         [self textFieldShouldReturn:name_field];
         [self textFieldShouldReturn:note_field];

        break;
      }
      case CELL_NOTE: {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
      }
      default:
         break;
   }
}
#endif // 0

- (void) dealloc
{
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
   if (textField.tag == TEXTFIELD_NAME)
      self.name = textField.text;
   else if (textField.tag == TEXTFIELD_NOTE)
      self.note = textField.text;

   [textField resignFirstResponder];
   return YES;
}

- (void) updatePriority
{
   self.priority = [NSString stringWithFormat:@"%d", priority_segment.selectedSegmentIndex];
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
   [self textFieldShouldReturn:(UITextField *)[self.view viewWithTag:TEXTFIELD_NAME]];
   [self textFieldShouldReturn:(UITextField *)[self.view viewWithTag:TEXTFIELD_NOTE]];
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

	
   UITextField *name_field = [[UITextField alloc] initWithFrame:
      CGRectMake(margin_left, margin_top, CGRectGetWidth(self.view.frame)-margin_left, column_height)];
   name_field.placeholder = @"what...";
   name_field.returnKeyType = UIReturnKeyDone;
   name_field.delegate = self;
   name_field.tag = TEXTFIELD_NAME;
   if (name)
      name_field.text = name;
   [name_field becomeFirstResponder];
   [self.view addSubview:name_field];
   [name_field release];

   UITextField *note_field = [[UITextField alloc] initWithFrame:CGRectMake(margin_left, margin_top+column_height, CGRectGetWidth(self.view.frame)-margin_left, column_height)];
   note_field.placeholder = @"note...";
   note_field.returnKeyType = UIReturnKeyDone;
   note_field.delegate = self;
   name_field.tag = TEXTFIELD_NOTE;
   [self.view addSubview:note_field];
   [note_field release];

   // setup priority segment
   NSArray *priority_items = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
   priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame)/2-64, 40)];
   for (int i=0; i<priority_items.count; i++)
      [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];

   [priority_segment addTarget:self action:@selector(updatePriority) forControlEvents:UIControlEventValueChanged];
   priority_segment.selectedSegmentIndex = 0;
   [self.view addSubview:priority_segment];

   UICCalendarPicker *picker = [[UICCalendarPicker alloc] initWithFrame:CGRectMake(0.0f, 120, 204.0f, 234.0f)];
   [picker setDelegate:self];
   [picker showInView:self.view];
   [picker release];

#if 0
   if (due_date) {
      NSString *dd = [[due_date componentsSeparatedByString:@"T"] objectAtIndex:0];
      NSArray *da  = [dd componentsSeparatedByString:@"-"];

      cell.text = [NSString stringWithFormat:@"%@/%@",
         [da objectAtIndex:1], [da objectAtIndex:2]];
   } else {
      //cell.text = @"...";
   }
#endif // 0

   /*
   UILabel *list_label = [[UILabel alloc] init];
   list_label.text = list.name;
   [self.view addSubview:list_label];
   [list_label release];
   */
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
   //[self.tableView reloadData];
}

@end
