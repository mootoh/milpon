//
//  OverviewViewController.h
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@interface OverviewViewController : UITableViewController
{
   NSArray *headers;
   NSArray *tasks;
   NSMutableArray *due_tasks;
   BOOL needs_scroll_to_today;
   BOOL showCompleted;
}

@property (nonatomic, retain) NSArray *headers;

@end
// set vim:ft=objc:
