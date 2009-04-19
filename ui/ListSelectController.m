//
//  ListSelectController.m
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListSelectController.h"
#import "ListProvider.h"
#import "AddTaskViewController.h"
#import "RTMList.h"

@implementation ListSelectController

@synthesize parent;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       self.title = @"List";
    }
    return self;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[ListProvider sharedListProvider] lists].count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
   static NSString *CellIdentifier = @"ListSelectCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }
   
   RTMList *list = [[[ListProvider sharedListProvider] lists] objectAtIndex:indexPath.row];
   cell.text = list.name;
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   //self.parent.list = [[[ListProvider sharedListProvider] lists] objectAtIndex:indexPath.row]];
   [self.navigationController popViewControllerAnimated:YES];
   [self.parent updateView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
   [super dealloc];
}


@end
