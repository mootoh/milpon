//
//  MPAddTaskViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/24/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPAddTaskViewController.h"

@implementation MPAddTaskViewController
@synthesize nameField, prioritySegments, nameCell, dueCell, priorityCell, listCell, tagCell, rruleCell, locationCell, noteCell;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = @"Add Task";

   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   UIBarButtonItem *doneButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
   doneButton.enabled = NO;
   self.navigationItem.leftBarButtonItem = cancelButton;
   self.navigationItem.rightBarButtonItem = doneButton;
   [cancelButton release];
   [doneButton release];

   nameField = [[UITextField alloc] initWithFrame:CGRectZero];
   nameField.placeholder = @"What to do...";
   nameField.font = [UIFont systemFontOfSize:20];
   //   self.tableView.allowsSelection = NO;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 2; // basic + detail
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   if (section == 0)
      // name, list, priority, due & due time
      return 4;
   else
      return 0;
      // tags, rrule, location, note
      // return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   if (section == 0) return nil;
   return @"Detail";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0) {
      switch (indexPath.row) {
         case 0:
            return nameCell.frame.size.height;
         case 1:
            return priorityCell.frame.size.height;
         case 2:
            return dueCell.frame.size.height;
         case 3:
            return listCell.frame.size.height;            
         default:
            break;
      }
   }
   return 0.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0) {
      switch (indexPath.row) {
         case 0:
            return nameCell;
         case 1:
            return priorityCell;
         case 2:
            return dueCell;
         case 3:
            listCell.textLabel.text = @"Inbox";
            return listCell;
         default:
            break;
      }
   }
   
   static NSString *CellIdentifier = @"AddTaskCell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   }
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
   if (indexPath.section == 0) {
      switch (indexPath.row) {
         case 0: {
            nameField.frame = CGRectMake(30, 10, cell.contentView.frame.size.width-64, 40);
            [cell.contentView addSubview:nameField];
            [nameField becomeFirstResponder];
            
            cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_target.png"]];
         } break;
         case 1:
            cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]];
            cell.textLabel.text = @"Due";
            break;
         case 2:
            cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_priority_1.png"]];

            // setup priority segment
            NSArray *priority_items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
            UISegmentedControl *priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(50, 6, CGRectGetWidth(self.view.frame)-104-10, 32)];
            for (int i=0; i<priority_items.count; i++)
               [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];
            
            priority_segment.selectedSegmentIndex = 3;
            [cell.contentView addSubview:priority_segment];
            [priority_segment release];
            
            break;
         case 3:
            cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]];
            cell.textLabel.text = @"List";
            break;
      }
   }

   return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row != 0) {
      [nameField resignFirstResponder];
   }  
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc
{
   [nameField release];
   [super dealloc];
}

#pragma mark -

- (void) cancel
{
   [self dismissModalViewControllerAnimated:YES];
}

- (void) done
{
   // save the task properties.
   [self dismissModalViewControllerAnimated:YES];
}

@end