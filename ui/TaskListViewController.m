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
#import "Collection.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "RTMTag.h"
#import "RTMTaskCell.h"
#import "TaskProvider.h"
#import "AddTaskViewController.h"

@implementation TaskListViewController

@synthesize tasks, collection;

- (void) reloadFromDB
{
   if (tasks) [tasks release];
   if ([collection isKindOfClass:[RTMList class]]) {
      tasks = [[[TaskProvider sharedTaskProvider] tasksInList:((RTMList *)collection).iD showCompleted:showCompleted] retain];
   } else {
      tasks = [[[TaskProvider sharedTaskProvider] tasksInTag:[((RTMTag *)collection).iD integerValue] showCompleted:showCompleted] retain];
   }
}

- (id)initWithStyle:(UITableViewStyle)style withCollection:(NSObject <Collection> *)cols;
{
   if (self = [super initWithStyle:style]) {
      self.collection = cols;
      self.title = [cols name];
      showCompleted = NO;
      [self reloadFromDB];

      UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:[collection isKindOfClass:[RTMList class]] ? @selector(addTaskInList) : @selector(addTaskInTag)];
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
   if ([collection isKindOfClass:[RTMList class]]) {
      return [[TaskProvider sharedTaskProvider] tasksInList:((RTMList *)collection).iD showCompleted:showCompleted].count;
   } else {
      return [[TaskProvider sharedTaskProvider] tasksInTag:[((RTMTag *)collection).iD integerValue] showCompleted:showCompleted].count;
   }
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
   [collection release];
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
   atvController.list = (RTMList *)self.collection;

   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [self presentModalViewController:navc animated:NO];
   [navc release];
   [atvController release];
}

- (IBAction) addTaskInTag
{
   AddTaskViewController *atvController = [[AddTaskViewController alloc] initWithStyle:UITableViewStylePlain];
   [atvController.tags addObject:(RTMTag *)self.collection];
   
   UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:atvController];
   [self presentModalViewController:navc animated:NO];
   [navc release];
   [atvController release];
}

@end
