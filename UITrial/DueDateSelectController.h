//
//  TrialDueDateSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTaskViewController;
@class UICCalendarPicker;

@interface DueDateSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
   IBOutlet UITableView *theTableView;
   AddTaskViewController *parent;
   UICCalendarPicker *calendar_picker;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) AddTaskViewController *parent;

@end