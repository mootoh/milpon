//
//  TaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Milpon.h"

@class AttributeView;
@class RTMList;
@class RTMTask;

@interface DueLabel : UILabel
{
   BOOL toggleCalendarDisplay;
   UIViewController *viewController;
}

- (void) setViewController:(UIViewController *)vc;

@end


@interface TaskViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, TaskEditDelegate>
{
   RTMTask *task;
   IBOutlet DueLabel      *due;
   IBOutlet UIButton      *priorityButton;
   IBOutlet UIPageControl *notePages;
   IBOutlet AttributeView *note_field;
   UIView  *dialogView;
   NSArray *prioritySelections;
}

@property (nonatomic, retain) RTMTask *task;

- (void) updateDue;
- (void) edit_name;
- (void) edit_due;
- (void) setDue:(NSDate *)date;
- (void) setList:(RTMList *)list;
- (void) setNote:(NSString *)note;
- (void) updateView;

@end
