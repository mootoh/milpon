//
//  TrialDueDateSelectController.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "Milpon.h"

@interface DueDateSelectController : UITableViewController
{
   UIViewController <TaskEditDelegate> *parent;
}

@property (nonatomic, retain) UIViewController <TaskEditDelegate> *parent;

@end
