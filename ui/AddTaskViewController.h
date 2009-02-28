//
//  AddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMList;

@interface AddTaskViewController : UITableViewController
{
   UITextField *text_input;
   UIButton *due_button;
   UISegmentedControl *priority_segment;

   NSString *list;
   NSDate *due;
   NSMutableSet *tags;
   NSString *note;
}

@property (nonatomic, retain) NSString *list;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSMutableSet *tags;
@property (nonatomic, retain) NSString *note;

- (IBAction) cancel;
- (IBAction) save;

@end
