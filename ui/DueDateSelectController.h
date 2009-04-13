//
//  TrialDueDateSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "Milpon.h"

@class UICCalendarPicker;

@interface DueDateSelectController : UITableViewController
{
   UIViewController <TaskEditDelegate> *parent;
   UICCalendarPicker *calendar_picker;
}

@property (nonatomic, retain) UIViewController <TaskEditDelegate> *parent;

@end
