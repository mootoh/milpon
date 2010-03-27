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

- (void) setCollector:(NSObject <TaskCollection> *)clctr
{
   collector = [clctr retain];
   collection = [[collector collection] retain];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return collection.count;
}

#define LISVIEWCELL_TASK_COUNT_TAG 1

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *MyIdentifier = @"TaskCollectionViewCell";
   
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
      task_count.backgroundColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];
      task_count.textColor = [UIColor whiteColor];
      task_count.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
      [cell addSubview:task_count];
   } else {
      task_count = (UILabel *)[cell viewWithTag:LISVIEWCELL_TASK_COUNT_TAG];
   }
   
   // Set up the cell
   NSObject <Collection> *cols = [collection objectAtIndex:indexPath.row];
   cell.textLabel.text = [cols name];
   
   task_count.text = [NSString stringWithFormat:@"%d", [cols taskCount]];
   [cell setNeedsDisplay];
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSObject <Collection> *cols = [collection objectAtIndex:indexPath.row];
   
   // Navigation logic
   TaskListViewController *ctrl = [[TaskListViewController alloc] initWithStyle:UITableViewStylePlain withCollection:cols];
   
   // Push the detail view controller
   [[self navigationController] pushViewController:ctrl animated:YES];
   [ctrl release];
}

- (void) dealloc
{
   [collection release];
   [super dealloc];
}

@end