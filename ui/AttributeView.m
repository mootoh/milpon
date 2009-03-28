//
//  AttributeView.m
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "AttributeView.h"

@implementation AttributeView

@synthesize icon, text, line_width, in_editing;

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor whiteColor];
      line_width = 1.0f;
      in_editing = NO;
   }
   return self;
}

- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();

   [icon drawAtPoint:CGPointMake(0, 0)];

   if (! in_editing) {
      CGContextSetTextDrawingMode(context, kCGTextFill);
      CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);

      [text drawInRect:CGRectMake(24, 0, rect.size.width-24, rect.size.height)
         withFont:[UIFont systemFontOfSize:14]
         lineBreakMode:UILineBreakModeTailTruncation];
   }

   CGContextSetRGBStrokeColor(context, 0.0f, 51.0f/256.0f, 102.0f/256.0f, 1.0);
   CGContextSetLineWidth(context, line_width);
   CGContextMoveToPoint(context, 0.0f, rect.size.height-1.0f);
   CGContextAddLineToPoint(context, rect.size.width, rect.size.height-1.0f);
   CGContextStrokePath(context);
}


- (void)dealloc
{
   [edit_delegate release];
   [icon release];
   [text release];
   [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   if (edit_delegate)
      objc_msgSend(edit_delegate,action);
#if 0
   toggleCalendarDisplay = toggleCalendarDisplay ? NO : YES;
   if (toggleCalendarDisplay) {
			UICCalendarPicker *picker = [[UICCalendarPicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 204.0f, 234.0f)];
      [picker setDelegate:viewController];
      [picker showInView:self.superview];
      [picker release];
   }
#endif // 0
}

- (void) setDelegate:(id) dlg asAction:(SEL)act
{
   edit_delegate = dlg;
   action = act;
}

@end
