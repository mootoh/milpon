#import <UIKit/UIKit.h>

@interface UICCalendarPickerDateButton : UIButton {
	UIButton *button;
	NSDate *date;
}

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) NSDate *date;

@end
