//
//  ListtViewController.m
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "ListViewController.h"
#import "AppDelegate.h"
#import "RTMList.h"
#import "TaskListViewController.h"

@implementation ListViewController

- (id) initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
   }
   return self;
}

- (void)viewDidLoad
{
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   lists = [[RTMList allLists] retain];
   self.title = @"List";   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *MyIdentifier = @"TaskList";

   UILabel *task_count = nil;

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

      // task count label
      task_count = [[[UILabel alloc] initWithFrame:
         CGRectMake(cell.frame.size.width-60, 11.0, 30.0, 22.0)] autorelease];
      task_count.tag = 1;
      task_count.font = [UIFont systemFontOfSize:16.0];
      task_count.textAlignment = UITextAlignmentCenter;
      task_count.backgroundColor = [UIColor colorWithRed:0.0078 green:0.421 blue:0.921 alpha:1.0];
      task_count.textColor = [UIColor whiteColor];
      task_count.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
      [cell addSubview:task_count];
   } else {
      task_count = (UILabel *)[cell.contentView viewWithTag:1];
   }

   // Set up the cell
   RTMList *lst = [lists objectAtIndex:indexPath.row];
   cell.text = lst.name;

   task_count.text = [NSString stringWithFormat:@"%d", [lst taskCount]];
   [cell setNeedsDisplay];
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   RTMList *lst = [lists objectAtIndex:indexPath.row];

   // Navigation logic
   TaskListViewController *ctrl = [[TaskListViewController alloc] initWithStyle:UITableViewStylePlain withList:lst];

   // Push the detail view controller
   [[self navigationController] pushViewController:ctrl animated:YES];
   [ctrl release];
}

/*
   Override if you support editing the list
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

   if (editingStyle == UITableViewCellEditingStyleDelete) {
// Delete the row from the data source
[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}	
if (editingStyle == UITableViewCellEditingStyleInsert) {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}	
}
*/


/*
   Override if you support conditional editing of the list
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the specified item to be editable.
return YES;
}
*/


/*
   Override if you support rearranging the list
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
   }
   */


/*
   Override if you support conditional rearranging of the list
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the item to be re-orderable.
return YES;
}
*/ 


- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
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
	if (lists) [lists release];
   [super dealloc];
}

@end
