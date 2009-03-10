//
//  TaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMTask.h"

@class TaskViewController;

@interface DueLabel : UILabel
{
   BOOL toggleCalendarDisplay;
   UIViewController *viewController;
}

- (void) setViewController:(UIViewController *)vc;

@end


@interface TaskViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
   RTMTask *task;
   IBOutlet UITextField   *name;
   IBOutlet UITextField   *url;
   IBOutlet UITextField   *location;
   IBOutlet UITextField   *repeat;
   IBOutlet UITextField   *estimate;
   IBOutlet UITextField   *postponed;
   IBOutlet DueLabel      *due;
   IBOutlet UIButton      *priorityButton;
   IBOutlet UITextField   *list;
   IBOutlet UITextView    *noteView;
   IBOutlet UIPageControl *notePages;
   IBOutlet UILabel       *tags;
   UIView  *dialogView;
   NSArray *prioritySelections;
}

@property (nonatomic, retain) RTMTask *task;

- (void) updateDue;

@end
