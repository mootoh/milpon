//
//  OverviewViewController.m
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "OverviewViewController.h"
#import "AppDelegate.h"
#import "RTMTask.h"
#import "RTMTaskCell.h"
#import "TaskViewController.h"
#import "TaskProvider.h"
#import "MilponHelper.h"

@implementation OverviewViewController

@synthesize headers;

enum {
   OVERDUE,
   TODAY,
   TOMORROW,
   THIS_WEEK
} section_type;

static const int SECTIONS = 4;

- (void) reloadFromDB
{
   // cleanup old data
   if (tasks) [tasks release];
   if (due_tasks) [due_tasks release];

   // load
   tasks = [[[TaskProvider sharedTaskProvider] tasks] retain];
   due_tasks = [[NSMutableArray alloc] init];
   for (int i=0; i<SECTIONS; i++)
      [due_tasks addObject:[NSMutableArray array]];

   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss zzz"];

   unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSDateComponents *comps = [calendar components:unitFlags fromDate:now];

   NSDate *today = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
          [comps year], [comps month], [comps day]]];

   for (RTMTask *task in tasks) {
      if (!task.due || task.due == [MilponHelper sharedHelper].invalidDate) continue;
      NSDateComponents *comp_due = [calendar components:unitFlags fromDate:task.due];
      NSDate *due_date = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d_00:00:00 GMT",
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

- (id) initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      needs_scroll_to_today = YES;
      tasks = nil;
      due_tasks = nil;

      self.headers = [NSArray arrayWithObjects:@"Outdated", @"Today", @"Tomorrow", @"7 days", nil];

		NSDate *today = [NSDate date];
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateStyle:NSDateFormatterMediumStyle];
      formatter.dateFormat = @"M/dd (EEE)";
      self.title = [formatter stringFromDate:today];
      [formatter release];

      [self reloadFromDB];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(addTask)];
   self.navigationItem.rightBarButtonItem = addButton;
   [addButton release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[due_tasks objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"RTMTaskCell";

   RTMTaskCell *cell = (RTMTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[RTMTaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }

   RTMTask *task = [[due_tasks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
   NSAssert2(task, @"task should not be nil for (section, row) = (%d, %d)", indexPath.section, indexPath.row);
   cell.task = task;

   [cell setNeedsDisplay]; // TODO: causes slow
   return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return [headers objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   TaskViewController *ctrl = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];

   RTMTask *task = [[due_tasks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
   ctrl.task = task;

   [[self navigationController] pushViewController:ctrl animated:YES];
   [ctrl release];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   if (needs_scroll_to_today && [[due_tasks objectAtIndex:TODAY] count] > 0) {
      NSUInteger ints[2] = {TODAY, 0};
      NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
      [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
      needs_scroll_to_today = NO;
   }
}

- (void)dealloc
{
   [headers release];
   [tasks release];
   [due_tasks release];
   [super dealloc];
}

@end
