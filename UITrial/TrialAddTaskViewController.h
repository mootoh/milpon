//
//  TrialAddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrialAddTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
   IBOutlet UITableView *theTableView;
   UITextField *text_input;
   UIButton *due_button;
   UISegmentedControl *priority_segment;
   NSString *list;
   NSDate *due;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) NSString *list;
@property (nonatomic, retain) NSDate *due;

- (IBAction) cancel;
- (IBAction) save;

@end
