//
//  AddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMList;

@interface AddTaskViewController : UITableViewController <UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate> {
  NSString *name;
  NSString *priority;
  NSString *location_id;
  NSString *due_date;
  NSString *estimate;

  NSArray *lists;
  RTMList *list;

  UITextField *name_field;
  UITextField *estimate_field;
  UISegmentedControl *priority_segment;

  UIBarButtonItem *cancelButton;
  UIBarButtonItem *submitButton;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) RTMList *list;
@property (nonatomic, retain) NSString *priority;
@property (nonatomic, retain) NSString *location_id;
@property (nonatomic, retain) NSString *due_date;
@property (nonatomic, retain) NSString *estimate;

- (IBAction) save;

@end
