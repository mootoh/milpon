//
//  TrialListSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTaskViewController;

@interface ListSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
   IBOutlet UITableView *theTableView;
   id list_provider;
   AddTaskViewController *parent;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) AddTaskViewController *parent;

@end