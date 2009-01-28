//
//  TrialTagViewController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrialAddTaskViewController;

@interface TrialTagViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
   IBOutlet UITableView *theTableView;
   id tag_provider;
   TrialAddTaskViewController *parent;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) TrialAddTaskViewController *parent;

@end