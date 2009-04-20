//
//  TrialListSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class AddTaskViewController;

@interface ListSelectController : UITableViewController
{
   AddTaskViewController *parent;
}

@property (nonatomic, retain) AddTaskViewController *parent;

@end