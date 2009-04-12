//
//  TagViewController.m
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagViewController.h"
#import "TagProvider.h"
#import "RTMTag.h"
#import "logger.h"
#import "TagListViewController.h"

@implementation TagViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   editing_ = NO;
   tp = [[TagProvider sharedTagProvider] retain];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   LOG(@"tp tags count = %d", [tp tags].count);
   return [tp tags].count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"TagViewCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }

   RTMTag *tag = (RTMTag *)[[tp tags] objectAtIndex:indexPath.row];
   cell.text = [NSString stringWithFormat:@"%@ (%d)", tag.name, [tp taskCountInTag:tag]];

   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   RTMTag *tg = [[tp tags] objectAtIndex:indexPath.row];

   // Navigation logic
   TagListViewController *ctrl = [[TagListViewController alloc] initWithStyle:UITableViewStylePlain tag:tg];

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
   [tp release];
   [super dealloc];
}

- (IBAction) add
{
   NSDictionary *param = [NSDictionary dictionaryWithObject:@"added tag" forKey:@"name"];
   [tp create:param];
   
   NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
   
   [self.tableView beginUpdates];
   //[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
   [self.tableView endUpdates];
}

- (IBAction) toggleEdit
{
   editing_ = ! editing_;
   [self setEditing:editing_ animated:YES];
}

@end
