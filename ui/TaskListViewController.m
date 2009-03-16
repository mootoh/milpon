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
#import "TaskProvider.h"
#import "AddTaskViewController.h"

@implementation TaskListViewController

@synthesize list, tasks;

- (void) reloadFromDB
{
   if (tasks) [tasks release];
   tasks = [[[TaskProvider sharedTaskProvider] tasksInList:list] retain];
}

- (id)initWithStyle:(UITableViewStyle)style withList:(RTMList *)lst
{
   if (self = [super initWithStyle:style]) {
      self.list = lst;
      self.title = lst.name;
      [self reloadFromDB];

      UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskInList)];
      self.navigationItem.rightBarButtonItem = addButton;
      [addButton release];
   }
   return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[TaskProvider sharedTaskProvider] tasksInList:list].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


- (void)dealloc
{
   [list release];
   [tasks release];
   [super dealloc];
}


- (void)viewDidLoad
{
   [super viewDidLoad];
}


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

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (IBAction) addTaskInList
{
   AddTaskViewController *atvController = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];
   atvController.list = self.list;

   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [self presentModalViewController:navc animated:NO];
   [navc release];
   [atvController release];
}

@end
