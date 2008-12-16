#import <UIKit/UIKit.h>

typedef enum {
	UICCalendarPickerStyleDefault,
	UICCalendarPickerStyleBlackOpaque,
	UICCalendarPickerStyleBlackTranslucent,
} UICCalendarPickerStyle;

typedef enum {
	UICCalendarPickerSelectionModeSingleSelection,
	UICCalendarPickerSelectionModeMultiSelection,
	UICCalendarPickerSelectionModeRangeSelection,
} UICCalendarPickerSelectionMode;

@interface UICCalendarPicker : UIImageView {
	id delegate;
	
	UICCalendarPickerStyle style;
	UICCalendarPickerSelectionMode selectionMode;
	
	NSDate *pageDate;
	NSDate *currentDate;
	NSDate *today;
	
	NSInteger lastSelected;
	NSMutableArray *selectedDates;
	
	NSDate *rangeStartDate;
	NSDate *rangeEndDate;
	
	NSDate *minDate;
	NSDate *maxDate;
	
	NSCalendar *gregorian;
	NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) id delegate;

@property (nonatomic) UICCalendarPickerStyle style;
@property (nonatomic) UICCalendarPickerSelectionMode selectionMode;

@property (nonatomic, retain) NSMutableArray *selectedDates;

@property (nonatomic, retain) NSDate *pageDate;

@property (nonatomic, retain, setter=setMinDate:) NSDate *minDate;
@property (nonatomic, retain, setter=setMaxDate:) NSDate *maxDate;

- (void)addSelectedDate:(NSDate *)aDate;
- (void)addSelectedDates:(NSArray *)dates;
- (void)showInView:(UIView *)aView;
- (void)dismiss:(id)sender;

@end
