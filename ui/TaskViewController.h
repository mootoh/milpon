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

@interface TaskViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, TaskEditDelegate, HavingList, HavingTag>
{
   RTMTask *task;
   IBOutlet UIButton      *priorityButton;
   IBOutlet UIPageControl *notePages;
   AttributeView *note_field;
   IBOutlet UIImageView   *recurrentImageView;
   UIView  *dialogView;
   NSArray *prioritySelections;
}

@property (nonatomic, retain) RTMTask *task;

- (void) edit_name;
- (void) edit_due;
- (void) setDue:(NSDate *)date;
- (void) setList:(RTMList *)list;
- (void) setNote:(NSString *)note;
- (void) updateView;

@end
