#import <UIKit/UIKit.h>

@class UICCalendarPicker;

@protocol UICCalendarPickerDelegate

- (void)picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate;

@end
