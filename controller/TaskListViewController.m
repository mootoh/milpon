//
//  TaskListViewController.m
//  Milpon
//
//  Created by mootoh on 9/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "TaskListViewController.h"
#import "AppDelegate.h"
#import "TaskViewController.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "RTMTaskCell.h"

@implementation TaskListViewController

@synthesize list, tasks;

- (void) reloadFromDB
{
  [tasks release];
  tasks = nil;
  tasks = [[RTMTask tasksInList:list.iD inDB:db] retain];
}

- (id)initWithStyle:(UITableViewStyle)style withList:(RTMList *)lst
{
  if (self = [super initWithStyle:style]) {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    db = app.db;

    self.list = lst;
    self.title = lst.name;
    [self reloadFromDB];
  }
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [list taskCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"RTMTaskCell";
	
	RTMTaskCell *cell = (RTMTaskCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[RTMTaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	RTMTask *tsk = [tasks objectAtIndex:indexPath.row];

	// Configure the cell
  cell.task = tsk;
  [cell setNeedsDisplay];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic
	TaskViewController *ctrl = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
	RTMTask *tsk = [tasks objectAtIndex:indexPath.row];
	ctrl.task = tsk;
	
	// Push the detail view controller
	[[self navigationController] pushViewController:ctrl animated:YES];
	[ctrl release];
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
	}
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


- (void)dealloc {
  [list release];
  [tasks release];
  [db release];
	[super dealloc];
}


- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
