//
//  AddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMList;

@interface AddTaskViewController : UITableViewController <UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate>
{
   NSString *name;
   NSString *priority;
   NSString *due_date;

   NSArray *lists;
   RTMList *list;

   UITextField *name_field;
   UISegmentedControl *priority_segment;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *priority;
@property (nonatomic, retain) NSString *due_date;
@property (nonatomic, retain) RTMList *list;

- (IBAction) save;
- (void) commitTextFields;

@end
