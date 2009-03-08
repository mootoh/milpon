//
//  ScaffoldListViewController.h
//  Milpon
//
//  Created by mootoh on 3/6/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class ListProvider;

@interface ScaffoldListViewController : UITableViewController {
   ListProvider *lp;
   BOOL editing_;
}

- (IBAction) toggleEdit;
- (IBAction) add;

@end
