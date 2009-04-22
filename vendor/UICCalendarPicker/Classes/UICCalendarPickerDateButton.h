#import <UIKit/UIKit.h>
#import "UICCalendarPicker.h"

@interface UICCalendarPickerDateButton : UIButton {
	UIButton *button;
	NSDate *date;
	BOOL isToday;
	UICCalendarPickerDayOfWeek dayOfWeek;
	BOOL monthout;
	BOOL outOfRange;
}

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, getter=isToday, setter=setToday:) BOOL isToday;
@property (nonatomic) UICCalendarPickerDayOfWeek dayOfWeek;
@property (nonatomic) BOOL monthout;
@property (nonatomic) BOOL outOfRange;

@end
