//
//  HomeViewController.h
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ReloadableTableViewController.h"

@interface HomeViewController : UITableViewController <ReloadableTableViewControllerProtocol>
{
   enum {
      TODAY,
      TOMORROW,
      THIS_WEEK,
      OVERDUE
   } section_type;

   NSArray *headers;
   NSArray *tasks;
   NSMutableArray *due_tasks;
}

@property (nonatomic, retain) NSArray *headers;

@end
// set vim:ft=objc:
