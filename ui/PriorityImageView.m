//
//  PriorityImageView.m
//  Milpon
//
//  Created by mootoh on 11/24/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "PriorityImageView.h"
#import "logger.h"

@implementation PriorityImageView

static NSArray *s_icons;

+ (NSArray *) icons
{
   static BOOL first = YES;
   if (first) {
      NSMutableArray *ics = [[NSMutableArray alloc] init];
      for (int i=0; i<4; i++) {
         UIImage *img = [[UIImage alloc] initWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
               [NSString stringWithFormat:@"icon_priority_%d.png", i]]];
         [ics addObject:img];
         [img release];
      }
      s_icons = ics;
   }
   return s_icons;
}

/*
- (id) initWithImage:(UIImage *)image
{
   if (self = [super initWithImage:image]) {
*/
- (id) initWithFrame:(CGRect) frame
{
   if (self = [super initWithFrame:frame]) {
      self.userInteractionEnabled  = YES;

      // dialog
      dialog_displayed = NO;

      dialogView = [[UIView alloc] initWithFrame:
         CGRectMake(self.frame.origin.x, self.frame.origin.y+24, 44*4, 44)];
      dialogView.backgroundColor = [UIColor blackColor];
      //dialogView.hidden = YES;

      for (int i=0; i<4; i++) {
         UIImageView *imgView = [[UIImageView alloc] initWithImage:
            [[PriorityImageView icons] objectAtIndex:i]];
         imgView.frame = CGRectMake(i*44, 0, 44, 44);
         [dialogView addSubview:imgView];
         [imgView release];
      }

      [self.superview addSubview:dialogView];
   }
   return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   LOG(@"touchesBegan");

   if (dialog_displayed) {
      dialogView.hidden = YES;
   } else {
      dialogView.hidden = NO;
   }
   [dialogView setNeedsDisplay];

   dialog_displayed = ! dialog_displayed;
}

- (void) dealloc
{
   [dialogView release];
   [super dealloc];
}

@end
