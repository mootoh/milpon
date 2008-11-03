//
//  TaskEditCell.h
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditCell : UITableViewCell {
  NSString *label;
  UILabel *label_field;
}

@property (nonatomic, retain) NSString *label;

@end
