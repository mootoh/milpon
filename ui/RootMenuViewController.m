//
//  RootMenuViewController.m
//  Milpon
//
//  Created by mootoh on 4/12/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "RootMenuViewController.h"
#import "HomeViewController.h"
#import "ListViewController.h"
#import "TagViewController.h"

@implementation RootMenuViewController

enum sec_zero {
   SEC_ZERO_OVERVIEW,
   SEC_ZERO_LIST,
   SEC_ZERO_TAG,
   SEC_ZERO_COUNT
};

enum sec_one {
   SEC_ONE_REVIEW,
   SEC_ONE_SETTING,
   SEC_ONE_COUNT
};

- (id)initWithStyle:(UITableViewStyle)style {
   // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
   if (self = [super initWithStyle:style]) {
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"Milpon";

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
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
   [super viewWillDisappear:animated];
   }
   */
/*
   - (void)viewDidDisappear:(BOOL)animated {
   [super viewDidDisappear:animated];
   }
   */

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// Return YES for supported orientations
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];

   // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload {
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}
*/


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}

// Customize the number of rows in the table view.
   - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      if (section == 0)
         return SEC_ZERO_COUNT;
      if (section == 1)
         return SEC_ONE_COUNT;
      return 0;
   }

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

   static NSString *CellIdentifier = @"RootMenuCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }

   if (indexPath.section == 0) {
      switch (indexPath.row) {
      case SEC_ZERO_OVERVIEW:
         cell.text = @"Overview";
         break;
      case SEC_ZERO_LIST:
         cell.text = @"List";
         break;
      case SEC_ZERO_TAG:
         cell.text = @"Tag";
         break;
      default:
         break;
      }
   } else {
      switch (indexPath.row) {
      case SEC_ONE_REVIEW:
         cell.text = @"Review";
         break;
      case SEC_ONE_SETTING:
         cell.text = @"Setting";
         break;
      default:
         break;
      }
   }

   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // Navigation logic may go here. Create and push another view controller.
   // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
   // [self.navigationController pushViewController:anotherViewController];
   // [anotherViewController release];

   if (indexPath.section == 0) {
      switch (indexPath.row) {
      case SEC_ZERO_OVERVIEW: {
         HomeViewController *hvc = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
         [self.navigationController pushViewController:hvc animated:YES];
         [hvc release];
         break;
      }
      case SEC_ZERO_LIST: {
         ListViewController *lsvc = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
         [self.navigationController pushViewController:lsvc animated:YES];
         [lsvc release];
         break;
      }
      case SEC_ZERO_TAG: {
         TagViewController *tlvc = [[TagViewController alloc] initWithStyle:UITableViewStylePlain];
         [self.navigationController pushViewController:tlvc animated:YES];
         [tlvc release];
         break;
      }
      default:
         break;
      }
   } else {
#if 0
      switch (indexPath.row) {
      case SEC_ONE_REVIEW:
         cell.text = @"Review";
         break;
      case SEC_ONE_SETTING:
         cell.text = @"Setting";
         break;
      default:
         break;
      }
#endif // 0
   }
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
   [super dealloc];
}


@end

