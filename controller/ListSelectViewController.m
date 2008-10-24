//
//  ListSelectViewController.m
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ListSelectViewController.h"
#import "RTMDatabase.h"
#import "AppDelegate.h"
#import "RTMList.h"
#import "AddTaskViewController.h"

@implementation ListSelectViewController

@synthesize parent;

- (id)initWithStyle:(UITableViewStyle)style {
  if (self = [super initWithStyle:style]) {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RTMDatabase *db = app.db;
    lists = [[RTMList allLists:db] retain];
  }
  return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ListSelectViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
    RTMList * lst = [lists objectAtIndex:indexPath.row];
    cell.text = lst.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RTMList * lst = [lists objectAtIndex:indexPath.row];
  self.parent.list = lst;
  [self.parent.tableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
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
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
  [lists release];
    [super dealloc];
}


@end
