//
//  TaskEditCell.m
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "TaskEditCell.h"
#import "RTMList.h"

@implementation TaskEditCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
      label_field = [[UILabel alloc] initWithFrame:CGRectMake(4, 2, 52, CGRectGetHeight(self.frame)-4)];
      label_field.textAlignment = UITextAlignmentRight;
      label_field.font = [UIFont systemFontOfSize:12];
      label_field.textColor = [UIColor grayColor];
      self.font = [UIFont systemFontOfSize:14];
      self.indentationWidth = 30;
      self.indentationLevel = 1;
    }
    return self;
}

- (NSString *) label {
  return label;
}

- (void) setLabel:(NSString *)lab {
  label = [lab retain];
  label_field.text = label;
  [self addSubview:label_field];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
  
  // enter edit mode.
}


- (void)dealloc {
  [label_field release];
  [label release];
  [super dealloc];
}


@end
