//
//  TrialAddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

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
