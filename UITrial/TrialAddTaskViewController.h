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
}

@property (nonatomic, retain) UITableView *theTableView;

- (IBAction) cancel;
- (IBAction) save;

@end
