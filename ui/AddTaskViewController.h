//
//  AddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMList;

@interface AddTaskViewController : UITableViewController
{
   UITextField *name_field;
   UIButton *due_button;
   UISegmentedControl *priority_segment;

   RTMList *list;
   NSDate *due;
   NSMutableSet *tags;
   NSString *note;
}

@property (nonatomic, retain) RTMList *list;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSMutableSet *tags;
@property (nonatomic, retain) NSString *note;

- (IBAction) cancel;

/**
 * @brief create RTMTask from given fields, then close the view.
 * @todo: add rrule
 */
- (IBAction) save;

- (void) updateView;

@end
