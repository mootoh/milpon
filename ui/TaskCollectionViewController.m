//
//  TaskCollectionViewController.m
//  Milpon
//
//  Created by mootoh on 4/14/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TaskCollectionViewController.h"
#import "TaskCollection.h"
#import "TaskListViewController.h"
#import "Collection.h"

@implementation TaskCollectionViewController

@synthesize collector;

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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [collector collection].count;
}

#define LISVIEWCELL_TASK_COUNT_TAG 1

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *MyIdentifier = @"ListViewCell";
   
   UILabel *task_count = nil;
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      // task count label
      task_count = [[[UILabel alloc] initWithFrame:
                     CGRectMake(cell.frame.size.width-60, 11.0, 30.0, 22.0)] autorelease];
      task_count.tag = LISVIEWCELL_TASK_COUNT_TAG;
      task_count.font = [UIFont systemFontOfSize:16.0];
      task_count.textAlignment = UITextAlignmentCenter;
      task_count.backgroundColor = [UIColor colorWithRed:0.0078 green:0.421 blue:0.921 alpha:1.0];
      task_count.textColor = [UIColor whiteColor];
      task_count.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
      [cell addSubview:task_count];
   } else {
      task_count = (UILabel *)[cell.contentView viewWithTag:LISVIEWCELL_TASK_COUNT_TAG];
   }
   
   // Set up the cell
   NSArray *cols = [collector collection];
   NSObject <Collection> *collection = [cols objectAtIndex:indexPath.row];
   cell.text = [collection name];
   
   task_count.text = [NSString stringWithFormat:@"%d", [collection taskCount]];
   [cell setNeedsDisplay];
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSArray *cols = [collector collection];
   NSObject <Collection> *collection = [cols objectAtIndex:indexPath.row];
   
   // Navigation logic
   TaskListViewController *ctrl = [[TaskListViewController alloc] initWithStyle:UITableViewStylePlain withCollection:collection];
   
   // Push the detail view controller
   [[self navigationController] pushViewController:ctrl animated:YES];
   [ctrl release];
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

- (void)dealloc
{
    [super dealloc];
}


@end

