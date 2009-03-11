//
//  AttributeView.m
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "AttributeView.h"

@implementation AttributeView

@synthesize edit_delegate, icon, text, line_width;

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor whiteColor];
      line_width = 1.0f;
   }
   return self;
}

- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetTextDrawingMode(context, kCGTextFill);
   CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);

   [icon drawAtPoint:CGPointMake(0, 0)];

   [text drawInRect:CGRectMake(24, 0, rect.size.width-24, rect.size.height)
      withFont:[UIFont systemFontOfSize:14]
      lineBreakMode:UILineBreakModeTailTruncation];

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

@end
