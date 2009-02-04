//
//  TrialTagViewController.m
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagSelectController.h"
#import "TrialTagProvider.h"
#import "AddTaskViewController.h"

@implementation TagSelectController

@synthesize parent, selected_tags;

static UIImage *s_checkedIcon = nil;

+ (UIImage *)checkedIcon
{
   if (s_checkedIcon == nil)
      s_checkedIcon = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_checked.png"]];
   return s_checkedIcon;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
      tag_provider = [[TrialTagProvider alloc] init];
      self.title = @"¿Tags";
      selected_flags = [[NSMutableDictionary alloc] init];
   }
   return self;
}

- (void) setTags:(NSMutableSet *) tags
{
   self.selected_tags = tags;
   for (NSString *tag in [tag_provider tags]) {
      BOOL has = [selected_tags containsObject:tag];
      [selected_flags setObject:[NSNumber numberWithBool:has] forKey:tag];
   }      
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tag_provider tags].count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }

   NSString *tag = [[tag_provider tags] objectAtIndex:indexPath.row];
   cell.text = tag;
   
   if ([[selected_flags objectForKey:tag] boolValue]) {
      UIImageView *image_view = [[UIImageView alloc] initWithImage:[TagSelectController checkedIcon]];
      cell.accessoryView = image_view;
      [image_view release];
   } else {
      cell.accessoryView = nil;
   }
   
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSAssert(self.parent, @"parent should be set");
   NSString *tag = [[tag_provider tags] objectAtIndex:indexPath.row];
   if ([[selected_flags objectForKey:tag] boolValue]) {
      [selected_flags setObject:[NSNumber numberWithBool:NO] forKey:tag];
      [selected_tags removeObject:tag];
   } else {
      [selected_flags setObject:[NSNumber numberWithBool:YES] forKey:tag];
      [selected_tags addObject:tag];
   }
   [tableView reloadData]; // TODO: should update only selected row.
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self.parent.tableView reloadData]; // TODO: should reload only tag row
	[super viewWillDisappear:animated];
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


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

- (void)dealloc {
   [selected_flags release];
   [tag_provider release];
   [super dealloc];
}


@end
