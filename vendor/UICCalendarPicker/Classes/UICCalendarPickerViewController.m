#import "UICCalendarPickerViewController.h"
#import "UICCalendarPicker.h"
#import "UICCalendarPickerDateButton.h"
#import "Debug.h"

@implementation UICCalendarPickerViewController

@synthesize textView;
@synthesize calendarButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        ;
    }
    return self;
}

- (void)dealloc {
	[calendarButton release];
	[textView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showDefault:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeSmall];
	[calendarPicker setDelegate:self];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}
- (IBAction)showMultiSelection:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeMedium];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeMultiSelection];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showRangeSelection:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeLarge];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeRangeSelection];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showLastMonthPresent:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeExtraLarge];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeMultiSelection];
	[calendarPicker setPageDate:[NSDate dateWithTimeIntervalSinceNow:-1 * (60 * 60 * 24 * 30)]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showWeekRangeActive:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] init];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeMultiSelection];
	[calendarPicker setMinDate:[NSDate date]];
	[calendarPicker setMaxDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 7]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showMonthRangeActive:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] init];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeRangeSelection];
	[calendarPicker setMinDate:[NSDate date]];
	[calendarPicker setMaxDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 30]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showRangeActiveFromNow:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] init];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeRangeSelection];
	[calendarPicker setMinDate:[NSDate date]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showRangeActiveToNow:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] init];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeRangeSelection];
	[calendarPicker setMaxDate:[NSDate date]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showDateSelected:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] init];
	[calendarPicker setDelegate:self];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeMultiSelection];
	[calendarPicker addSelectedDate:[NSDate date]];
	[calendarPicker addSelectedDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 *2]];
	[calendarPicker showInView:self.view animated:YES];
	[calendarPicker release];
}

- (IBAction)showDateCustom:(id)sender {
	UICCalendarPicker *calendarPicker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeMedium];
	[calendarPicker setDelegate:self];
	[calendarPicker setDataSource:self];
	[calendarPicker setTitleText:[NSString stringWithUTF8String:"予約カレンダー"]];
	[calendarPicker setWeekText:[NSArray arrayWithObjects:
								 [NSString stringWithUTF8String:"日"], [NSString stringWithUTF8String:"月"], [NSString stringWithUTF8String:"火"], 
								 [NSString stringWithUTF8String:"水"], [NSString stringWithUTF8String:"木"], [NSString stringWithUTF8String:"金"], 
								 [NSString stringWithUTF8String:"土"], nil]];
	[calendarPicker setSelectionMode:UICCalendarPickerSelectionModeMultiSelection];
	[calendarPicker addSelectedDate:[NSDate date]];
	[calendarPicker addSelectedDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 *2]];
	CGRect frame = calendarButton.frame;
	[calendarPicker showAtPoint:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height) inView:self.view animated:YES];
	[calendarPicker release];
}

#pragma mark <UICCalendarPickerDelegate> Methods

- (void)picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate {
	LOG_CURRENT_METHOD;
	[textView setText:[NSString stringWithFormat:@"%@", selectedDate]];
}

#pragma mark <UICCalendarPickerDataSource> Methods

- (NSString *)picker:(UICCalendarPicker *)picker textForYearMonth:(NSDate *)aDate {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"] autorelease]];
	[dateFormatter setDateFormat:@"yyyy MMM"];
	return [dateFormatter stringFromDate:aDate];
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateToday:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateWeekday:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSaturday:(UICCalendarPickerDateButton *)button {
	[button setBackgroundImage:[UIImage imageNamed:@"uiccalendar_cell_custom1.png"] forState:UIControlStateNormal];
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSunday:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateMonthOut:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateOutOfRange:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSelected:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateBlank:(UICCalendarPickerDateButton *)button {
	;
}

- (void)picker:(UICCalendarPicker *)picker buttonForDate:(UICCalendarPickerDateButton *)button {
	if ([[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 10 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 15 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 18 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 21) {
		[button setEnabled:NO];
		[button setTitle:nil forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uiccalendar_cell_custom2.png"] forState:UIControlStateDisabled];
	}
	if ([[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 11 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 12 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 13 ||
		[[button.date dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] == 14) {
		[button setTitle:[NSString stringWithUTF8String:"満"] forState:UIControlStateDisabled];
		[button setEnabled:NO];
		[button setTitle:nil forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uiccalendar_cell_disabled.png"] forState:UIControlStateDisabled];
	}
}

@end
