//
//  RTMTaskCell.m
//  Milpon
//
//  Created by mootoh on 10/13/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMTaskCell.h"
#import "RTMTask.h"
#import "MilponHelper.h"

@implementation RTMTaskCell

@synthesize task;

static NSArray *s_priorityColors;
static NSArray *s_check_box_images;

+ (NSArray *)priorityColors
{
   if (nil == s_priorityColors) {
      s_priorityColors = [NSArray arrayWithObjects:
         [UIColor colorWithRed:0.917 green:0.321 blue:0.0 alpha:1.0],
         [UIColor colorWithRed:0.0 green:0.376 blue:0.749 alpha:1.0],
         [UIColor colorWithRed:0.207 green:0.604 blue:1.0 alpha:1.0],
         nil];
      [s_priorityColors retain];
   }
   return s_priorityColors;
}

+ (NSArray *) check_box_images
{
   if (nil == s_check_box_images) {
      s_check_box_images = [NSArray arrayWithObjects:
         [UIImage imageNamed:@"checkBox.png"],
         [UIImage imageNamed:@"checkBoxChecked.png"],
         nil];
      [s_check_box_images retain];
   }
   return s_check_box_images;
}

- (void) prepareForReuse
{
   if (task) [task release];
   task = nil;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
   if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
      self.opaque = YES;
      //self.backgroundColor = [UIColor whiteColor];
      self.userInteractionEnabled = YES;

      completeButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 1, 42, 42)];
      [completeButton setImage:[[RTMTaskCell check_box_images] objectAtIndex:0] forState:UIControlStateNormal];
      [completeButton setImage:[[RTMTaskCell check_box_images] objectAtIndex:0] forState:UIControlStateHighlighted];
      completeButton.opaque = YES;
      [completeButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchDown];  
      [self.contentView addSubview:completeButton];
   }
   return self;
}

- (void) drawRect:(CGRect)rect
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   [super drawRect:rect];
   NSAssert(task, @"task should be set");
	
   CGColorRef textColor;
   [self renderWithStatus];
   textColor = task.is_completed ? [UIColor grayColor].CGColor : [UIColor blackColor].CGColor;

   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetTextDrawingMode(context, kCGTextFill);
   CGContextSetFillColorWithColor(context, textColor);

   //[task.name drawInRect:CGRectMake(0, 2, 212, 100)
   [task.name drawInRect:CGRectMake(52, 14, 202, 14)
      withFont:[UIFont systemFontOfSize:14]
      lineBreakMode:UILineBreakModeTailTruncation];

   switch ([task.priority intValue]) {
      case 0:
         CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.0);
         break;
      case 1:
         CGContextSetRGBStrokeColor(context, 0.917, 0.321, 0.0, 1.0);
         break;
      case 2:
         CGContextSetRGBStrokeColor(context, 0.0, 0.376, 0.749, 1.0);
         break;
      case 3:
         CGContextSetRGBStrokeColor(context, 0.207, 0.604, 1.0, 1.0);
         break;
      default:
         break;
   }
   CGContextSetLineWidth(context, 8.0);

   // Draw a single line from left to right
   CGContextMoveToPoint(context, 4.0f, 0.0);
   CGContextAddLineToPoint(context, 4.0f, self.frame.size.height);
   CGContextStrokePath(context);

   if (task.due) {
      dueLabel.hidden = NO;
      NSCalendar *calendar = [NSCalendar currentCalendar];
      unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
      NSDateComponents *comps = [calendar components:unitFlags fromDate:task.due];

      NSString *due = [NSString stringWithFormat:@"%d/%d", [comps month], [comps day]];
      //dueLabel.text = due;
      [due drawInRect:CGRectMake(262, 2, 30, 14)
         withFont:[UIFont systemFontOfSize:10]];

      if ([task.estimate isEqualToString:@""]) {
         //estimateLabel.hidden = YES;
      } else {
         //estimateLabel.hidden = NO;
         //estimateLabel.text = task.estimate;
         [task.estimate drawInRect:CGRectMake(262, rect.size.height-16, 25, 14)
            withFont:[UIFont systemFontOfSize:10]];
      }
   } else {
      dueLabel.hidden = YES;
   }

	[pool release];
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   [super setSelected:selected animated:animated];
// Configure the view for the selected state
}
*/

- (void)dealloc
{
   [completeButton release];
   [estimateLabel release];
   [dueLabel release];
   [nameLabel release];
   if (task) [task release];
   [super dealloc];
}

- (IBAction) toggle
{
   if ([task is_completed])
      [task uncomplete];
   else
      [task complete];
   [self setNeedsDisplay];
}

- (void) renderWithStatus
{
   if ([task is_completed]) {
      [completeButton setImage:[[RTMTaskCell check_box_images] objectAtIndex:1] forState:UIControlStateNormal]; 

      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSetRGBStrokeColor(context, 0.941, 0.464, 0.460, 1.0);
      CGContextSetLineWidth(context, 4.0);
      CGContextMoveToPoint(context, 42.0, 22.0);
      CGContextAddLineToPoint(context, 42+212, 22.0);
      CGContextStrokePath(context);
   } else {
      [completeButton setImage:[[RTMTaskCell check_box_images] objectAtIndex:0] forState:UIControlStateNormal];
   }
}

#if 0
- (BOOL)canBecomeFirstResponder
{
   return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog(@"first ? %d", [self isFirstResponder]);
   NSLog(@"can become first ? %d", [self canBecomeFirstResponder]);
   NSLog(@"become %d", [self becomeFirstResponder]);
   CGPoint pt = [[touches anyObject] locationInView:self];
   startLocation = pt;
   NSLog(@"touchesBegan: (%f, %f)", pt.x, pt.y);

   UITableView *parent = (UITableView *)self.superview;
   parent.scrollEnabled = NO;
   [self setEditing:YES animated:YES];

   //[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   CGPoint pt = [[touches anyObject] locationInView:self];
   NSLog(@"touchesEnded: (%f, %f) moved =(%f, %f)", pt.x, pt.y,
         startLocation.x-pt.x, startLocation.y-pt.y);

   UITableView *parent = (UITableView *)self.superview;
   parent.scrollEnabled = YES;
}

/*
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   CGPoint pt = [[touches anyObject] locationInView:self];
   NSLog(@"touchesMoved: (%f, %f) moved =(%f, %f)", pt.x, pt.y,
   startLocation.x-pt.x, startLocation.y-pt.y);
}  
*/
#endif // 0
@end
