//
//  TrialDueDateSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrialAddTaskViewController;
@class UICCalendarPicker;

@interface TrialDueDateSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
   IBOutlet UITableView *theTableView;
   TrialAddTaskViewController *parent;
   UICCalendarPicker *calendar_picker;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) TrialAddTaskViewController *parent;

@end