//
//  ListSelectViewController.m
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ListSelectViewController.h"
#import "AppDelegate.h"
#import "RTMList.h"
#import "AddTaskViewController.h"
#import "ListProvider.h"

@implementation ListSelectViewController

@synthesize parent;

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      lists = [[[ListProvider sharedListProvider] lists] retain];
   }
   return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
[super viewDidLoad];
}
*/


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
   static NSString *CellIdentifier = @"ListSelectViewCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }
   // Configure the cell
   RTMList *lst = [lists objectAtIndex:indexPath.row];
   cell.text = lst.name;
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   RTMList * lst = [lists objectAtIndex:indexPath.row];
   self.parent.list = lst;
   //[self.parent.tableView reloadData];
   [self.parent.view setNeedsDisplay];
   [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
   [lists release];
   [super dealloc];
}

@end
