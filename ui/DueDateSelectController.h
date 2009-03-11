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

@interface DueDateSelectController : UITableViewController
{
   AddTaskViewController *parent;
   UICCalendarPicker *calendar_picker;
}

@property (nonatomic, retain) AddTaskViewController *parent;

@end
