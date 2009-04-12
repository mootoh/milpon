//
//  TagListViewController.m
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagListViewController.h"
#import "TagProvider.h"
#import "TaskProvider.h"
#import "RTMTag.h"
#import "RTMTaskCell.h"
#import "TaskViewController.h"
#import "AddTaskViewController.h"

@implementation TagListViewController

@synthesize tag, tasks;

- (void) reloadFromDB
{
   if (tasks) [tasks release];
   tasks = [[[TaskProvider sharedTaskProvider] tasksInTag:tag] retain];
}

- (id)initWithStyle:(UITableViewStyle)style tag:(RTMTag *)tg
{
   if (self = [super initWithStyle:style]) {
      self.tag = tg;
      self.title = tag.name;

      UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskInTag)];
      self.navigationItem.rightBarButtonItem = addButton;

      [self reloadFromDB];
   }
   return self;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [[TagProvider sharedTagProvider] taskCountInTag:tag];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

   static NSString *MyIdentifier = @"RTMTaskCell";

   RTMTaskCell *cell = (RTMTaskCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
   if (cell == nil) {
      cell = [[[RTMTaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
   }

   RTMTask *tsk = [tasks objectAtIndex:indexPath.row];
   NSAssert(tsk, @"task should not be nil");
   cell.task = tsk;
   [cell setNeedsDisplay]; // TODO: causes slow
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Navigation logic
   TaskViewController *ctrl = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
   RTMTask *tsk = [[[TaskProvider sharedTaskProvider] tasksInTag:tag] objectAtIndex:indexPath.row];
   ctrl.task = tsk;

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


- (void)dealloc {
   [tag release];
   [super dealloc];
}

- (IBAction) addTaskInTag
{
   AddTaskViewController *atvController = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];
   [atvController.tags addObject:self.tag];

   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [self presentModalViewController:navc animated:NO];
   [navc release];
   [atvController release];
}

@end
