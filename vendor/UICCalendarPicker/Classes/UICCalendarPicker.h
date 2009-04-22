#import <UIKit/UIKit.h>

@class UICCalendarPickerDateButton;

typedef enum {
	UICCalendarPickerSizeSmall,
	UICCalendarPickerSizeMedium,
	UICCalendarPickerSizeLarge,
	UICCalendarPickerSizeExtraLarge,
} UICCalendarPickerSize;

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

typedef enum {
	UICCalendarPickerDayOfWeekSunday = 1,
	UICCalendarPickerDayOfWeekMonday,
	UICCalendarPickerDayOfWeekTuesday,
	UICCalendarPickerDayOfWeekWednesday,
	UICCalendarPickerDayOfWeekThursday,
	UICCalendarPickerDayOfWeekFriday,
	UICCalendarPickerDayOfWeekSaturday,
} UICCalendarPickerDayOfWeek;

@class UICCalendarPicker;

@protocol UICCalendarPickerDelegate<NSObject>
@optional
- (void)picker:(UICCalendarPicker *)picker pushedCloseButton:(id)sender;
- (void)picker:(UICCalendarPicker *)picker pushedPrevButton:(id)sender;
- (void)picker:(UICCalendarPicker *)picker pushedNextButton:(id)sender;
- (void)picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate;
@end

@protocol UICCalendarPickerDataSource<NSObject>
@optional
- (NSString *)picker:(UICCalendarPicker *)picker textForYearMonth:(NSDate *)aDate;
- (void)picker:(UICCalendarPicker *)picker buttonForDateToday:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateWeekday:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateSaturday:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateSunday:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateMonthOut:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateOutOfRange:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateSelected:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDateBlank:(UICCalendarPickerDateButton *)button;
- (void)picker:(UICCalendarPicker *)picker buttonForDate:(UICCalendarPickerDateButton *)button;
@end

@interface UICCalendarPicker : UIImageView {
	id<UICCalendarPickerDelegate> delegate;
	id<UICCalendarPickerDataSource> dataSource;
	
	UICCalendarPickerStyle style;
	UICCalendarPickerSelectionMode selectionMode;
	
	NSString *titleText;
	NSArray *weekText;
	
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

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id dataSource;

@property (nonatomic) UICCalendarPickerStyle style;
@property (nonatomic) UICCalendarPickerSelectionMode selectionMode;

@property (nonatomic, retain, setter=setTitleText:) NSString *titleText;
@property (nonatomic, retain, setter=setWeekText:) NSArray *weekText;

@property (nonatomic, retain, readonly) NSMutableArray *selectedDates;

@property (nonatomic, retain) NSDate *pageDate;
@property (nonatomic, retain) NSDate *today;

@property (nonatomic, retain, setter=setMinDate:) NSDate *minDate;
@property (nonatomic, retain, setter=setMaxDate:) NSDate *maxDate;

- (id)init;
- (id)initWithSize:(UICCalendarPickerSize)viewSize;
- (void)addSelectedDate:(NSDate *)aDate;
- (void)addSelectedDates:(NSArray *)dates;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)showAtPoint:(CGPoint)point inView:(UIView *)aView animated:(BOOL)animated;
- (void)dismiss:(id)sender animated:(BOOL)animated;

@end
