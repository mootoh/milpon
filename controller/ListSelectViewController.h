//
//  ListSelectViewController.h
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTaskViewController;

@interface ListSelectViewController : UITableViewController {
  NSArray *lists;
  AddTaskViewController *parent;
}

@property (nonatomic, retain) AddTaskViewController *parent;

@end
