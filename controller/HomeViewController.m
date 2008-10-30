//
//  HomeViewController.m
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "RTMTask.h"
#import "RTMTaskCell.h"
#import "TaskViewController.h"

@implementation HomeViewController

@synthesize headers;

static const int SECTIONS = 4;

- (void) reloadFromDB {
  /*
   * cleanup old data
   */
  [tasks release];
  tasks = nil;
  [due_tasks release];
  due_tasks = nil;

  /*
   * load
   */
  tasks = [[RTMTask tasks:db] retain];
  due_tasks = [[NSMutableArray alloc] init];
  for (int i=0; i<SECTIONS; i++)
    [due_tasks addObject:[NSMutableArray array]];

  NSDate *now = [NSDate date];
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
  [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss zzz"];

  unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *comps = [calendar components:unitFlags fromDate:now];

  NSDate *today = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d-00:00:00 GMT",
         [comps year], [comps month], [comps day]]];

  //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

  for (RTMTask *task in tasks) {
    NSString *due = task.due;
    if ([due isEqualToString:@""]) continue;
    NSDate *due_date = [formatter dateFromString:due];
    NSDateComponents *comp_due = [calendar components:unitFlags fromDate:due_date];
    due_date = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d-00:00:00 GMT",
             [comp_due year], [comp_due month], [comp_due day]]];

    NSTimeInterval interval = [due_date timeIntervalSinceDate:today];
    if (interval < 0) {
      [[due_tasks objectAtIndex:OVERDUE] addObject:task];
    } else if (interval < 24*60*60) {
      [[due_tasks objectAtIndex:TODAY] addObject:task];
    } else if (interval < 24*60*60*2) {
      [[due_tasks objectAtIndex:TOMORROW] addObject:task];
    } else if (interval < 24*60*60*7) {
      [[due_tasks objectAtIndex:THIS_WEEK] addObject:task];
    }
  }
}

- (id) initWithStyle:(UITableViewStyle)style {
  if (self = [super initWithStyle:style]) {
    self.title = @"Overview";

    self.headers = [NSArray arrayWithObjects:@"Today", @"Tomorrow", @"This Week", @"Outdated", nil];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    db = [app.db retain];

    [self reloadFromDB];
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
  return SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[due_tasks objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"RTMTaskCell";

  RTMTaskCell *cell = (RTMTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[RTMTaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  // Configure the cell
  RTMTask *task = [[due_tasks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  cell.task = task;
  [cell setNeedsDisplay];
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [headers objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TaskViewController *ctrl = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
  RTMTask *task = [[due_tasks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	ctrl.task = task;
	
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


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
  [self.tableView deselectRowAtIndexPath:selected animated:NO];
  //[self.tableView reloadData];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  [super viewWillAppear:animated];
  NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
  [self.tableView deselectRowAtIndexPath:selected animated:NO];
  [self.tableView reloadData];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
  [db release];
  [headers release];
  [tasks release];
  [due_tasks release];
  [super dealloc];
}

@end
