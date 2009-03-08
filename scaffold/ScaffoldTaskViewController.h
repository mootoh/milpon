//
//  ScaffoldTaskViewController.h
//  Milpon
//
//  Created by mootoh on 3/6/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class TaskProvider;

@interface ScaffoldTaskViewController : UITableViewController {
   TaskProvider *tp;
   BOOL editing_;
}

- (IBAction) add;
- (IBAction) toggleEdit;

@end
