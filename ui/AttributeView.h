//
//  AttributeView.h
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@interface AttributeView : UIView {
   id edit_delegate;
   IBOutlet UIImage *icon;
   IBOutlet NSString *text;
   float line_width;
}

@property (nonatomic, retain) id edit_delegate;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) float line_width;

@end
