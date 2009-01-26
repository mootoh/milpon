//
//  TrialAddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrialAddTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
   IBOutlet UITableView *theTableView;
   UITextField *text_input;
   UIButton *due_button;
   UISegmentedControl *priority_segment;
   NSString *list;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) NSString *list;

- (IBAction) cancel;
- (IBAction) save;

@end
