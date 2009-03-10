//
//  ScaffoldTagViewController.h
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class TagProvider;

@interface ScaffoldTagViewController : UITableViewController {
   TagProvider *tp;
   BOOL editing_;
}

- (IBAction) toggleEdit;
- (IBAction) add;

@end
