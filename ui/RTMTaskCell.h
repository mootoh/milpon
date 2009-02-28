//
//  RTMTaskCell.h
//  Milpon
//
//  Created by mootoh on 10/13/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMTask;

@interface RTMTaskCell : UITableViewCell {
  RTMTask *task;
  UILabel *nameLabel;
  UILabel *dueLabel;
  UILabel *estimateLabel;
  BOOL is_completed;
  CGPoint startLocation;
  UIButton *completeButton;
}

@property (nonatomic,retain) RTMTask *task;

- (IBAction) toggle;
- (void) renderWithStatus;

@end
