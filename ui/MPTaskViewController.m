//
//  MPTaskViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/10/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTaskViewController.h"
#import "RTMAPI+Task.h"
#import "RTMAPI+Timeline.h"
#import "MPHelper.h"
#import "MPLogger.h"

@implementation MPTaskViewController
@synthesize fetchedResultsController, managedObjectContext;
@synthesize taskObject;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(syncTask)];
   self.toolbarItems = [NSArray arrayWithObjects:syncButton, nil];
   [syncButton release];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   NSManagedObject *taskseriesObject = [taskObject valueForKey:@"taskSeries"];
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterShortStyle];

   switch (indexPath.section) {
      case 0: // TaskSeries
         switch (indexPath.row) {
            case 0:
               cell.textLabel.text = @"iD";
               cell.detailTextLabel.text = [[taskseriesObject valueForKey:@"iD"] description];
               break;
            case 1:
               cell.textLabel.text = @"name";
               cell.detailTextLabel.text = [[taskseriesObject valueForKey:@"name"] description];
               break;
            case 2:
               cell.textLabel.text = @"craeted";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskseriesObject valueForKey:@"created"]];
               break;
            case 3:
               cell.textLabel.text = @"modified";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskseriesObject valueForKey:@"modified"]];
               break;
            case 4:
               cell.textLabel.text = @"rrule";
               cell.detailTextLabel.text = [[taskseriesObject valueForKey:@"rrule"] description];
               break;
            case 5:
               cell.textLabel.text = @"url";
               cell.detailTextLabel.text = [[taskseriesObject valueForKey:@"url"] description];
               break;
            case 6: {
               cell.textLabel.text = @"tags";
               NSString *tag_str = @"";
               for (NSManagedObject *tag in [taskseriesObject valueForKey:@"tags"])
                  tag_str = [tag_str stringByAppendingFormat:@"%@ ", [tag valueForKey:@"name"]];
               cell.detailTextLabel.text = tag_str;
               break;
            }
            default:
               break;
         }
         break;
      case 1: // Task
         switch (indexPath.row) {
            case 0:
               cell.textLabel.text = @"iD";
               cell.detailTextLabel.text = [[taskObject valueForKey:@"iD"] description];
               break;
            case 1:
               cell.textLabel.text = @"added";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskObject valueForKey:@"added"]];
               break;
            case 2:
               cell.textLabel.text = @"completed";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskObject valueForKey:@"completed"]];
               break;
            case 3:
               cell.textLabel.text = @"deleted";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskObject valueForKey:@"deleted_"]];
               break;
            case 4:
               cell.textLabel.text = @"due";
               cell.detailTextLabel.text = [dateFormatter stringFromDate:[taskObject valueForKey:@"due"]];
               break;
            case 5:
               cell.textLabel.text = @"estimate";
               cell.detailTextLabel.text = [[taskObject valueForKey:@"estimate"] description];
               break;
            case 6:
               cell.textLabel.text = @"has_due_time";
               cell.detailTextLabel.text = [[taskObject valueForKey:@"has_due_time"] description];
               break;
            case 7:
               cell.textLabel.text = @"postponed";
               cell.detailTextLabel.text = [[taskObject valueForKey:@"postponed"] description];
               break;
            case 8:
               cell.textLabel.text = @"priority";
               cell.detailTextLabel.text = [[taskObject valueForKey:@"priority"] description];
               break;
            default:
               break;
         }
         break;
      default:
         break;
   }
   [dateFormatter release];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   switch (section) {
      case 0: // TaskSeries attributes
         return 7;
      case 1: // Task attributes
         return 9;
      default:
         break;
   }
   return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   switch (section) {
      case 0:
         return @"TaskSeries";
      case 1:
         return @"Task";
      default:
         return nil;
   }
   return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   static NSString *CellIdentifier = @"TaskCell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
   }
   
   // Configure the cell...
   [self configureCell:cell atIndexPath:indexPath];
   
   return cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction) postpone
{
}

- (IBAction) setDue
{
}

- (IBAction) setName
{
}

- (IBAction) setEstimate
{
}

- (IBAction) setRepeatRule
{
}

@end