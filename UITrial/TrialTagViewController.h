//
//  TrialTagViewController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrialAddTaskViewController;

@interface TrialTagViewController : UITableViewController {
   id tag_provider;
   TrialAddTaskViewController *parent;
   NSMutableSet *selected_tags;
   NSMutableDictionary *selected_flags;
}

- (void) setTags:(NSMutableSet *) tags;

@property (nonatomic, retain) TrialAddTaskViewController *parent;
@property (nonatomic, retain) NSMutableSet *selected_tags;


@end