//
//  AttributeView.h
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@protocol AttributeViewDelegate
- (void) edit:(SEL)action;

@end // AttributeViewDelegate

@interface AttributeView : UIView
{
   id edit_delegate;
   SEL action;
   IBOutlet UIImage *icon;
   IBOutlet NSString *text;
   float line_width;
   BOOL in_editing;
}

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) float line_width;
@property (nonatomic) BOOL in_editing;

- (void) setDelegate:(id) dlg asAction:(SEL)act;

@end
