#import <UIKit/UIKit.h>
#import "UICCalendarPicker.h"

@interface UICCalendarPickerViewController : UIViewController {
	IBOutlet UITextView *textView;
	IBOutlet UIButton *calendarButton;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIButton *calendarButton;

- (IBAction)showDefault:(id)sender;
- (IBAction)showMultiSelection:(id)sender;
- (IBAction)showRangeSelection:(id)sender;
- (IBAction)showLastMonthPresent:(id)sender;
- (IBAction)showWeekRangeActive:(id)sender;
- (IBAction)showMonthRangeActive:(id)sender;
- (IBAction)showRangeActiveFromNow:(id)sender;
- (IBAction)showRangeActiveToNow:(id)sender;
- (IBAction)showDateSelected:(id)sender;
- (IBAction)showDateCustom:(id)sender;

@end

