//
//  DueDatePickViewController.h
//  Milpon
//
//  Created by mootoh on 10/18/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTaskViewController;

@interface DueDatePickViewController : UIViewController
{
   UIDatePicker *picker;
   AddTaskViewController *parent;
}

@property (nonatomic, retain) AddTaskViewController *parent;

@end
