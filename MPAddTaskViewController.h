//
//  MPAddTaskViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/24/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPAddTaskViewController : UITableViewController
{
   IBOutlet UITextField *nameField;
   IBOutlet UISegmentedControl *prioritySegments;

   // name, list, priority, due & due time
   IBOutlet UITableViewCell *nameCell;
   IBOutlet UITableViewCell *dueCell;
   IBOutlet UITableViewCell *priorityCell;
   IBOutlet UITableViewCell *listCell;

   // tags, rrule, location, note
   IBOutlet UITableViewCell *tagCell;
   IBOutlet UITableViewCell *rruleCell;
   IBOutlet UITableViewCell *locationCell;
   IBOutlet UITableViewCell *noteCell;
}

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UISegmentedControl *prioritySegments;
@property (nonatomic, retain) UITableViewCell *nameCell;
@property (nonatomic, retain) UITableViewCell *dueCell;
@property (nonatomic, retain) UITableViewCell *priorityCell;
@property (nonatomic, retain) UITableViewCell *listCell;
@property (nonatomic, retain) UITableViewCell *tagCell;
@property (nonatomic, retain) UITableViewCell *rruleCell;
@property (nonatomic, retain) UITableViewCell *locationCell;
@property (nonatomic, retain) UITableViewCell *noteCell;

@end