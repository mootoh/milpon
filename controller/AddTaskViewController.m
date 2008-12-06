//
//  AddTaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "AddTaskViewController.h"
#import "TaskEditCell.h"
#import "RTMList.h"
#import "AppDelegate.h"
#import "RTMDatabase.h"
#import "ListSelectViewController.h"
#import "RTMTask.h"
#import "RootViewController.h"
#import "DueDatePickViewController.h"

#define kAddTaskViewController @"AddTaskViewController"

@implementation AddTaskViewController

@synthesize name, list, priority, due_date, note;

enum {
   CELL_NAME = 0,
   CELL_PRIORITY,
   CELL_DUE,
   CELL_LIST,
   CELL_NOTE,
   CELL_TYPES
};

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      RTMDatabase *db = app.db;
      lists = [[RTMList allLists:db] retain];

      self.title = @"Add a Task";
      self.priority = @"0";
      self.tableView.bounces = NO;

      self.list = [lists objectAtIndex:0]; // list default: INBOX

      // footer for scroll
      UIView *fotterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
      self.tableView.tableFooterView = fotterView;
      [fotterView release];
   }
   return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return CELL_TYPES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   TaskEditCell *cell = (TaskEditCell *)[tableView dequeueReusableCellWithIdentifier:kAddTaskViewController];
   if (cell == nil) {
      cell = [[[TaskEditCell alloc] initWithFrame:CGRectZero reuseIdentifier:kAddTaskViewController] autorelease];
   }
   // Configure the cell
   switch (indexPath.row) {
      case CELL_NAME:
         cell.label = @"Name:";
         if (name)
            name_field.text = name;
         [cell.contentView addSubview:name_field];
         break;
      case CELL_PRIORITY:
         cell.label = @"Priority:";
         [cell.contentView addSubview:priority_segment];
         break;
      case CELL_LIST:
         cell.label = @"List:";
         cell.text = list.name;
         break;
      case CELL_DUE:
         cell.label = @"Due:";
         cell.text = due_date ? self.due_date : @"none";
         break;
      case CELL_NOTE:
         if (note)
            note_field.text = note;
         [cell.contentView addSubview:note_field];
         cell.label = @"Note:";
         break;
      default:
         break;
   }
   return cell;
}

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
      case CELL_PRIORITY: {
         [self textFieldShouldReturn:name_field];
         [self textFieldShouldReturn:note_field];
         break;
      }
      case CELL_DUE: {
         DueDatePickViewController *duePickController = [[DueDatePickViewController alloc] initWithNibName:nil bundle:nil];
         duePickController.parent = self;
         [self.navigationController pushViewController:duePickController animated:YES];
         [duePickController release];
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

- (void) dealloc
{
   [name release];
   [due_date release];
   [name_field release];
   [note_field release];
   [lists release];
   [list release];
   [priority_segment release];
   [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
}

- (void) viewDidDisappear:(BOOL)animated
{
}

- (void) didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (CGFloat) pickerView:(UIPickerView *)pickerViewrowHeightForComponent:(NSInteger)component
{
   return 2.0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   return @"yey";
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
   return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
   return 1;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
   if (textField == name_field)
      self.name = textField.text;
   else if (textField == note_field)
      self.note = textField.text;

   [textField resignFirstResponder];
   return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
   UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
   NSIndexPath *path = [self.tableView indexPathForCell:cell];
   [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

   // store it to the DB
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMDatabase *db = app.db;

   NSArray *keys = [NSArray arrayWithObjects:@"name", @"due", @"list_id", @"priority", @"note", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      name,
      due_date ? due_date : @"",
      list.iD,
      priority,
      note,
      nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [RTMTask createAtOffline:params inDB:db];

   [self close];
}

- (void) loadView
{
   [super loadView];

   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   self.navigationItem.leftBarButtonItem = cancelButton;
   [cancelButton release];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
   [submitButton release];

   name_field = [[UITextField alloc] initWithFrame:CGRectMake(32, 12, CGRectGetWidth(self.view.frame)-32, CGRectGetHeight(self.view.frame)-8)];
   name_field.placeholder = @"...";
   name_field.returnKeyType = UIReturnKeyDone;
   name_field.delegate = self;

   note_field = [[UITextField alloc] initWithFrame:CGRectMake(32, 12, CGRectGetWidth(self.view.frame)-32, CGRectGetHeight(self.view.frame)-8)];
   note_field.placeholder = @"...";
   note_field.returnKeyType = UIReturnKeyDone;
   note_field.delegate = self;

   // setup priority segment
   NSArray *priority_items = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
   priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(32, 6, CGRectGetWidth(self.view.frame)-64, 32)];
   for (int i=0; i<priority_items.count; i++)
      [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];

   [priority_segment addTarget:self action:@selector(updatePriority) forControlEvents:UIControlEventValueChanged];
   priority_segment.selectedSegmentIndex = 0;
}

@end
