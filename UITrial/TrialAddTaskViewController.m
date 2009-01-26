//
//  TrialAddTaskViewController.m
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TrialAddTaskViewController.h"
#import "TrialNoteEditController.h"
#import "TrialListSelectController.h"

@implementation TrialAddTaskViewController

enum {
   ROW_NAME = 0,
   ROW_DUE_PRIORITY,
   ROW_LIST,
   ROW_TAG,
   ROW_NOTE,
   ROW_COUNT
};

@synthesize theTableView, list;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      self.title = @"Add";
      self.list = @"Inbox";
   }
   return self;
}

- (void) viewDidLoad
{
   theTableView.rowHeight = 40;

   /*
    * Navigation buttons
    */
   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   self.navigationItem.leftBarButtonItem = cancelButton;
   [cancelButton release];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
   [submitButton release];

   // task name
   text_input = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, 300, 40)];
   [text_input setFont:[UIFont systemFontOfSize:20.0f]];
   text_input.placeholder = @"what to do...";
   
   // due button
   due_button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
   due_button.frame = CGRectMake(10, 4, 64, 32);
   due_button.font = [UIFont systemFontOfSize:14];
   [due_button setTitle:@"due" forState:UIControlStateNormal];
   [due_button addTarget:self action:@selector(selectDue) forControlEvents:UIControlEventTouchDown];
   
   // setup priority segment
   NSArray *priority_items = [NSArray arrayWithObjects:@"-", @"3", @"2", @"1", nil];
   priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(84, 4, CGRectGetWidth(self.view.frame)-84-10, 32)];
   for (int i=0; i<priority_items.count; i++)
      [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];
   
   priority_segment.selectedSegmentIndex = 0;
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return ROW_COUNT;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   static NSString *CellIdentifier = @"TrialAddTaskViewCell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }
   
   switch (indexPath.row) {
      case ROW_NAME:
         [text_input becomeFirstResponder];
         [cell.contentView addSubview:text_input];
         break;
      case ROW_DUE_PRIORITY:
         [cell.contentView addSubview:due_button];
         [cell.contentView addSubview:priority_segment];
         break;
      case ROW_LIST:
         cell.text = [NSString stringWithFormat:@"List: %@", list];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         break;
      case ROW_TAG:
         cell.text = @"Tag";
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         break;
      case ROW_NOTE:
         cell.text = @"Note";
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         break;
      default:
         break;
   }

   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
   switch (indexPath.row) {
      case ROW_LIST: {
         TrialListSelectController *vc = [[TrialListSelectController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      case ROW_NOTE: {
         TrialNoteEditController *vc = [[TrialNoteEditController alloc] initWithNibName:nil bundle:nil];
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      default:
         break;
   }
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)dealloc {
   [priority_segment release];
   [due_button release];
   [text_input release];
   [super dealloc];
}

- (void) close
{
   [self dismissModalViewControllerAnimated:NO];
}


- (IBAction) cancel
{
   [self close];
}

- (IBAction) save
{
   NSLog(@"save");
}

- (void) selectDue
{
   NSLog(@"selectDue");
}

@end

