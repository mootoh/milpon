#import "UICCalendarPicker.h"
#import "UICCalendarPickerDateButton.h"
#import "Debug.h"

#define UICCALENDAR_CALENDAR_VIEW_WIDTH 204.0f
#define UICCALENDAR_CALENDAR_VIEW_HEIGHT 234.0f

#define UICCALENDAR_CONTROL_BUTTON_SMALL_WIDTH 25.0f
#define UICCALENDAR_CONTROL_BUTTON_SMALL_HEIGHT 15.0f
#define UICCALENDAR_CONTROL_BUTTON_MEDIUM_WIDTH 27.0f
#define UICCALENDAR_CONTROL_BUTTON_MEDIUM_HEIGHT 16.0f
#define UICCALENDAR_CONTROL_BUTTON_LARGE_WIDTH 30.0f
#define UICCALENDAR_CONTROL_BUTTON_LARGE_HEIGHT 18.0f
#define UICCALENDAR_CONTROL_BUTTON_EXTRALARGE_WIDTH 32.0f
#define UICCALENDAR_CONTROL_BUTTON_EXTRALARGE_HEIGHT 19.0f

#define UICCALENDAR_TITLE_FONT_SIZE 13.0f
#define UICCALENDAR_TITLE_LABEL_WIDTH 140.0f
#define UICCALENDAR_TITLE_LABEL_HEIGHT 15.0f

#define UICCALENDAR_TITLE_LABEL_TAG 100
#define UICCALENDAR_MONTH_LABEL_TAG 200
#define UICCALENDAR_WEEK_LABEL_TAG 300

#define UICCALENDAR_CELL_FONT_SIZE 13.0f
#define UICCALENDAR_CELL_SMALL_WIDTH 27.0f
#define UICCALENDAR_CELL_SMALL_HEIGHT 24.0f
#define UICCALENDAR_CELL_MEDIUM_WIDTH 29.0f
#define UICCALENDAR_CELL_MEDIUM_HEIGHT 26.0f
#define UICCALENDAR_CELL_LARGE_WIDTH 33.0f
#define UICCALENDAR_CELL_LARGE_HEIGHT 28.0f
#define UICCALENDAR_CELL_EXTRALARGE_WIDTH 35.0f
#define UICCALENDAR_CELL_EXTRALARGE_HEIGHT 31.0f

@interface UICCalendarPicker(Private)
- (void)closeButtonPushed:(id)sender;
- (void)prevButtonPushed:(id)sender;
- (void)nextButtonPushed:(id)sender;
- (void)dateButtonPushed:(id)sender;
- (void)moveLastMonth:(id)sender;
- (void)moveNextMonth:(id)sender;
- (void)setUpCalendarWithDate:(NSDate *)aDate;
- (void)addRangeDateObjects;
- (void)resetButtonAtributes:(UICCalendarPickerDateButton *)button;
- (void)resetButtonState:(UICCalendarPickerDateButton *)button;
- (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date;
@end

@implementation UICCalendarPicker

static float controlButtonWidth[] = 
{UICCALENDAR_CONTROL_BUTTON_SMALL_WIDTH, UICCALENDAR_CONTROL_BUTTON_MEDIUM_WIDTH, UICCALENDAR_CONTROL_BUTTON_LARGE_WIDTH, UICCALENDAR_CONTROL_BUTTON_EXTRALARGE_WIDTH};
static float controlButtonHeight[] = 
{UICCALENDAR_CONTROL_BUTTON_SMALL_HEIGHT, UICCALENDAR_CONTROL_BUTTON_MEDIUM_HEIGHT, UICCALENDAR_CONTROL_BUTTON_LARGE_HEIGHT, UICCALENDAR_CONTROL_BUTTON_EXTRALARGE_HEIGHT};
static float cellWidth[] = 
{UICCALENDAR_CELL_SMALL_WIDTH, UICCALENDAR_CELL_MEDIUM_WIDTH, UICCALENDAR_CELL_LARGE_WIDTH, UICCALENDAR_CELL_EXTRALARGE_WIDTH};
static float cellHeight[] = 
{UICCALENDAR_CELL_SMALL_HEIGHT, UICCALENDAR_CELL_MEDIUM_HEIGHT, UICCALENDAR_CELL_LARGE_HEIGHT, UICCALENDAR_CELL_EXTRALARGE_HEIGHT};

static UIImage *normalCell;
static UIImage *selectedCell;
static UIImage *disabledCell;
static UIImage *monthoutCell;
static UIImage *holidayCell;
static UIImage *todayCell;
static UIImage *todaySelectedCell;

static UIColor *normalColor;
static UIColor *selectedColor;
static UIColor *disabledColor;
static UIColor *monthoutColor;
static UIColor *holidayColor;

@synthesize titleText;
@synthesize weekText;

@synthesize delegate;
@synthesize dataSource;

@synthesize style;
@synthesize selectionMode;

@synthesize pageDate;
@synthesize today;

@synthesize selectedDates;

@synthesize minDate;
@synthesize maxDate;

+ (void)initialize {
	LOG_CURRENT_METHOD;
	normalCell = [[UIImage imageNamed:@"uiccalendar_cell_normal.png"] retain];
	selectedCell = [[UIImage imageNamed:@"uiccalendar_cell_selected.png"] retain];
	disabledCell = [[UIImage imageNamed:@"uiccalendar_cell_disabled.png"] retain];
	monthoutCell = [[UIImage imageNamed:@"uiccalendar_cell_monthout.png"] retain];
	holidayCell = [[UIImage imageNamed:@"uiccalendar_cell_holiday.png"] retain];
	todayCell = [[UIImage imageNamed:@"uiccalendar_cell_today.png"] retain];
	todaySelectedCell = [[UIImage imageNamed:@"uiccalendar_cell_today_selected.png"] retain];
	
	normalColor = [[UIColor colorWithRed:0.0f green:0.4f blue:0.86f alpha:1.0f] retain];
	selectedColor = [[UIColor blackColor] retain];
	disabledColor = [[UIColor lightGrayColor] retain];
	monthoutColor = [[UIColor darkGrayColor] retain];
	holidayColor = [[UIColor redColor] retain];
}

- (id)init {
	return [self initWithSize:UICCalendarPickerSizeMedium];
}

- (id)initWithSize:(UICCalendarPickerSize)viewSize {
	LOG_CURRENT_METHOD;
	if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, cellWidth[viewSize] * 7 - 6.0f + 21.0f, cellHeight[viewSize] * 6 - 5.0f + 95.0f)]) {
		self.titleText = @"Calendar";
		self.weekText = [NSArray arrayWithObjects:@"Su", @"Mo", @"Tu", @"We", @"Th", @"Fr", @"Sa", nil];
		
		[self setImage:[UIImage imageNamed:@"uiccalendar_background.png"]];
		
		[self setUserInteractionEnabled:YES];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_close.png"] forState:UIControlStateNormal];
		[closeButton setFrame:CGRectMake(self.frame.size.width - 31.0f - viewSize * 3, 6.0f, controlButtonWidth[viewSize], controlButtonHeight[viewSize])];
		[closeButton setShowsTouchWhenHighlighted:NO];
		[closeButton addTarget:self action:@selector(closeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];
		
		UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[prevButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_left_arrow.png"] forState:UIControlStateNormal];
		[prevButton setFrame:CGRectMake(6.0f, 36.0f, controlButtonWidth[viewSize], controlButtonHeight[viewSize])];
		[prevButton setShowsTouchWhenHighlighted:NO];
		[prevButton addTarget:self action:@selector(prevButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:prevButton];
		
		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_right_arrow.png"] forState:UIControlStateNormal];
		[nextButton setFrame:CGRectMake(self.frame.size.width - 31.0f - viewSize * 3, 36.0f, controlButtonWidth[viewSize], controlButtonHeight[viewSize])];
		[nextButton setShowsTouchWhenHighlighted:NO];
		[nextButton addTarget:self action:@selector(nextButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nextButton];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[titleLabel setTag:UICCALENDAR_TITLE_LABEL_TAG];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor blackColor]];
		[titleLabel setTextAlignment:UITextAlignmentLeft];
		[titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:UICCALENDAR_TITLE_FONT_SIZE]];
		[titleLabel setFrame:CGRectMake(11.0f, 6.0f + viewSize, self.frame.size.width, UICCALENDAR_TITLE_LABEL_HEIGHT)];
		[titleLabel setText:titleText];
		[self addSubview:titleLabel];
		[titleLabel release];
		
		UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[monthLabel setTag:UICCALENDAR_MONTH_LABEL_TAG];
		[monthLabel setBackgroundColor:[UIColor clearColor]];
		[monthLabel setTextColor:[UIColor blackColor]];
		[monthLabel setTextAlignment:UITextAlignmentCenter];
		[monthLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:UICCALENDAR_TITLE_FONT_SIZE]];
		[monthLabel setFrame:CGRectMake(self.frame.size.width / 2 - UICCALENDAR_TITLE_LABEL_WIDTH / 2, 36.0f + viewSize, UICCALENDAR_TITLE_LABEL_WIDTH, UICCALENDAR_TITLE_LABEL_HEIGHT)];
		[self addSubview:monthLabel];
		[monthLabel release];
		
		for (int i = 0; i < 7; i++) {
			UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			[weekLabel setTag:UICCALENDAR_WEEK_LABEL_TAG + i];
			[weekLabel setBackgroundColor:[UIColor clearColor]];
			[weekLabel setTextColor:[UIColor blackColor]];
			[weekLabel setTextAlignment:UITextAlignmentCenter];
			[weekLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:UICCALENDAR_TITLE_FONT_SIZE]];
			[weekLabel setFrame:CGRectMake(10.0f + (cellWidth[viewSize] - 1) * (i % 7), 63.0f, cellWidth[viewSize] , UICCALENDAR_TITLE_LABEL_HEIGHT)];
			[weekLabel setText:[weekText objectAtIndex:i]];
			[self addSubview:weekLabel];
			[weekLabel release];
		}
		
		for (int i = 0; i < 42; i++) {
			UICCalendarPickerDateButton *dateButton = [[UICCalendarPickerDateButton alloc] init];
			[dateButton setFrame:
			 CGRectMake(11.0f + cellWidth[viewSize] * (i % 7) - (i % 7), 84.0f + cellHeight[viewSize] * (i / 7) - (i / 7), cellWidth[viewSize], cellHeight[viewSize])];
			[dateButton setTag:i + 1];
			[dateButton addTarget:self action:@selector(dateButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
			[self resetButtonAtributes:dateButton];
			[self addSubview:dateButton];
			[dateButton release];
		}
		
		selectedDates = [[NSMutableArray alloc] init];
		
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
		
		NSDate *now = [NSDate date];
		NSDateComponents *todayComponents = [self getDateComponentsFromDate:now];
		today = [[gregorian dateFromComponents:todayComponents] retain];
		
		self.pageDate = today;
    }
    return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[dateFormatter release];
	[gregorian release];
	
	[maxDate release];
	[minDate release];
	
	[rangeEndDate release];
	[rangeStartDate release];
	
	[selectedDates release];
	
	[today release];
	[currentDate release];
	[pageDate release];
	
	[weekText release];
	[titleText release];
	
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark <UICCalendarPickerDataSource> Methods

- (NSString *)picker:(UICCalendarPicker *)picker textForYearMonth:(NSDate *)aDate {
	[dateFormatter setDateFormat:@"MMM yyyy"];
	return [dateFormatter stringFromDate:aDate];
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateToday:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setBackgroundImage:todayCell forState:UIControlStateNormal];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateToday:)]) {
		[dataSource picker:self buttonForDateToday:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateWeekday:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setBackgroundImage:normalCell forState:UIControlStateNormal];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateWeekday:)]) {
		[dataSource picker:self buttonForDateWeekday:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSaturday:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setBackgroundImage:normalCell forState:UIControlStateNormal];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateSaturday:)]) {
		[dataSource picker:self buttonForDateSaturday:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSunday:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setBackgroundImage:holidayCell forState:UIControlStateNormal];
	[button setTitleColor:holidayColor forState:UIControlStateNormal];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateSunday:)]) {
		[dataSource picker:self buttonForDateSunday:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateMonthOut:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setBackgroundImage:monthoutCell forState:UIControlStateNormal];
	[button setTitleColor:monthoutColor forState:UIControlStateNormal];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateMonthOut:)]) {
		[dataSource picker:self buttonForDateMonthOut:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateOutOfRange:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setEnabled:NO];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateOutOfRange:)]) {
		[dataSource picker:self buttonForDateOutOfRange:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateSelected:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	if (button.isToday) {
		[button setBackgroundImage:todaySelectedCell forState:UIControlStateSelected];
	} else {
		[button setBackgroundImage:selectedCell forState:UIControlStateSelected];
	}
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateSelected:)]) {
		[dataSource picker:self buttonForDateSelected:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDateBlank:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	[button setSelected:NO];
	[button setEnabled:NO];
	if ([dataSource respondsToSelector:@selector(picker:buttonForDateBlank:)]) {
		[dataSource picker:self buttonForDateBlank:button];
	}
}

- (void)picker:(UICCalendarPicker *)picker buttonForDate:(UICCalendarPickerDateButton *)button {
	[self resetButtonState:button];
	
	if (button.dayOfWeek == UICCalendarPickerDayOfWeekSunday) {
		[self picker:self buttonForDateSunday:button];
	} else if (button.dayOfWeek == UICCalendarPickerDayOfWeekSaturday) {
		[self picker:self buttonForDateSaturday:button];
	} else {
		[self picker:self buttonForDateWeekday:button];
	}
	
	if (button.isToday) {
		[self picker:self buttonForDateToday:button];
	}
	
	if (button.monthout) {
		[self picker:self buttonForDateMonthOut:button];
	}
	
	if (button.selected) {
		[self picker:self buttonForDateSelected:button];
	}
	
	if (button.outOfRange) {
		[self picker:self buttonForDateOutOfRange:button];
	}
	
	if (!button.date) {
		[self picker:self buttonForDateBlank:button];
	}
}

#pragma mark <UICCalendarPicker> Methods

- (void)setTitleText:(NSString *)text {
	if (text != titleText) {
		[titleText release];
	}
	titleText = [text retain];
	UILabel *titleLabel = (UILabel *)[self viewWithTag:UICCALENDAR_TITLE_LABEL_TAG];
	[titleLabel setText:text];
}

- (void)setWeekText:(NSArray *)text {
	if (text != weekText) {
		[weekText release];
	}
	weekText = [text retain];
	int i = 0;
	for (NSString *s in text) {
		UILabel *weekLabel = (UILabel *)[self viewWithTag:UICCALENDAR_WEEK_LABEL_TAG + i];
		[weekLabel setText:s];
		i++;
	}
}

- (void)setToday:(NSDate *)aDate {
	if (aDate != today) {
		[today release];
	}
	NSDateComponents *components = [self getDateComponentsFromDate:aDate];
	today = [[gregorian dateFromComponents:components] retain]; 
}

- (void)setMinDate:(NSDate *)aDate {
	if (aDate != minDate) {
		[minDate release];
	}
	NSDateComponents *components = [self getDateComponentsFromDate:aDate];
	minDate = [[gregorian dateFromComponents:components] retain]; 
}

- (void)setMaxDate:(NSDate *)aDate {
	if (aDate != maxDate) {
		[maxDate release];
	}
	NSDateComponents *components = [self getDateComponentsFromDate:aDate];
	maxDate = [[gregorian dateFromComponents:components] retain];
}

- (void)addSelectedDate:(NSDate *)aDate {
	NSDateComponents *components = [self getDateComponentsFromDate:aDate];
	[selectedDates addObject:[gregorian dateFromComponents:components]];
}

- (void)addSelectedDates:(NSArray *)dates {
	for (NSDate *date in dates) {
		NSDateComponents *components = [self getDateComponentsFromDate:date];
		[selectedDates addObject:[gregorian dateFromComponents:components]];
	}
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
	[self setCenter:CGPointMake(aView.frame.size.width / 2, self.frame.size.height / 2)];
	
	[self setUpCalendarWithDate:pageDate];
	
	if (animated) {
		[self setAlpha:0.0f];
		[aView addSubview:self];
		
		CGRect frame = [self frame];
		frame.origin.y = frame.origin.y - frame.size.height / 2;
		self.frame = frame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:self cache:NO];
		[self setAlpha:1.0f];
		frame.origin.y = frame.origin.y + frame.size.height / 2;
		self.frame = frame;
		[UIView commitAnimations];
	} else {
		[aView addSubview:self];
	}
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)aView animated:(BOOL)animated {
	[self setUpCalendarWithDate:pageDate];
	
	if (animated) {
		[self setAlpha:0.0f];
		[aView addSubview:self];
		
		CGRect frame = [self frame];
		frame.origin.x = point.x;
		frame.origin.y = point.y - frame.size.height / 2;
		self.frame = frame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:self cache:NO];
		[self setAlpha:1.0f];
		frame.origin.y = frame.origin.y + frame.size.height / 2;
		self.frame = frame;
		[UIView commitAnimations];
	} else {
		CGRect frame = [self frame];
		frame.origin.x = point.x;
		frame.origin.y = point.y;
		self.frame = frame;
		[aView addSubview:self];
	}
}

- (void)dismiss:(id)sender animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:self cache:NO];
		[self setAlpha:0.0f];
		CGRect frame = [self frame];
		frame.origin.y = frame.origin.y - frame.size.height / 2;
		self.frame = frame;
		[UIView commitAnimations];
	} else {
		[self removeFromSuperview];
	}
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[self removeFromSuperview];
}

#pragma mark Private Methods

- (void)resetButtonAtributes:(UICCalendarPickerDateButton *)button {
	[button setDate:nil];
	[button setToday:NO];
	[button setDayOfWeek:UICCalendarPickerDayOfWeekSunday];
	[button setMonthout:NO];
	[button setOutOfRange:NO];
	[button setEnabled:YES];
	[button setBackgroundImage:normalCell forState:UIControlStateNormal];
	[button setBackgroundImage:selectedCell forState:UIControlStateSelected];
	[button setBackgroundImage:disabledCell forState:UIControlStateDisabled];
	[button setTitleColor:normalColor forState:UIControlStateNormal];
	[button setTitleColor:selectedColor forState:UIControlStateSelected];
	[button setTitleColor:disabledColor forState:UIControlStateDisabled];
	[button setFont:[UIFont fontWithName:@"ArialMT" size:UICCALENDAR_CELL_FONT_SIZE]];
	[button setShowsTouchWhenHighlighted:NO];
}

- (void)resetButtonState:(UICCalendarPickerDateButton *)button {
	[button setBackgroundImage:normalCell forState:UIControlStateNormal];
	[button setBackgroundImage:selectedCell forState:UIControlStateSelected];
	[button setBackgroundImage:disabledCell forState:UIControlStateDisabled];
	[button setTitleColor:normalColor forState:UIControlStateNormal];
	[button setTitleColor:selectedColor forState:UIControlStateSelected];
	[button setTitleColor:disabledColor forState:UIControlStateDisabled];
	[button setFont:[UIFont fontWithName:@"ArialMT" size:UICCALENDAR_CELL_FONT_SIZE]];
	[button setShowsTouchWhenHighlighted:NO];
}

- (void)closeButtonPushed:(id)sender {
	if ([delegate respondsToSelector:@selector(picker:pushedCloseButton:)]) {
		[delegate picker:self pushedCloseButton:sender];
	} else {
		[self dismiss:sender animated:YES];
	}
}

- (void)prevButtonPushed:(id)sender {
	if ([delegate respondsToSelector:@selector(picker:pushedPrevButton:)]) {
		[delegate picker:self pushedPrevButton:sender];
	} else {
		[self moveLastMonth:sender];
	}
}

- (void)nextButtonPushed:(id)sender {
	if ([delegate respondsToSelector:@selector(picker:pushedNextButton:)]) {
		[delegate picker:self pushedNextButton:sender];
	} else {
		[self moveNextMonth:sender];
	}
}

- (void)dateButtonPushed:(id)sender {
	@synchronized(self) {
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)sender;
		if (selectionMode == UICCalendarPickerSelectionModeSingleSelection) {
			[selectedDates removeAllObjects];
			UICCalendarPickerDateButton *lastSelectedButton = (UICCalendarPickerDateButton *)[self viewWithTag:lastSelected];
			if (lastSelected == 0) {
				if ([[dateButton date] isEqualToDate:today]) {
					[dateButton setBackgroundImage:todaySelectedCell forState:UIControlStateSelected];
				} else {
					[dateButton setBackgroundImage:selectedCell forState:UIControlStateSelected];
				}
				[dateButton setSelected:YES];
				lastSelected = [dateButton tag];
				[selectedDates addObject:[dateButton date]];
			} else if (dateButton == lastSelectedButton) {
				[dateButton setSelected:NO];
				lastSelected = 0;
			} else {
				if ([[dateButton date] isEqualToDate:today]) {
					[dateButton setBackgroundImage:todaySelectedCell forState:UIControlStateSelected];
				} else {
					[dateButton setBackgroundImage:selectedCell forState:UIControlStateSelected];
				}
				[lastSelectedButton setSelected:NO];
				[dateButton setSelected:YES];
				lastSelected = [dateButton tag];
				[selectedDates addObject:[dateButton date]];
			}
		} else if (selectionMode == UICCalendarPickerSelectionModeMultiSelection) {
			if ([dateButton isSelected]) {
				[dateButton setSelected:NO];
				[selectedDates removeObject:[dateButton date]];
			} else {
				if ([[dateButton date] isEqualToDate:today]) {
					[dateButton setBackgroundImage:todaySelectedCell forState:UIControlStateSelected];
				} else {
					[dateButton setBackgroundImage:selectedCell forState:UIControlStateSelected];
				}
				[dateButton setSelected:YES];
				[selectedDates addObject:[dateButton date]];
			}
		} else {
			if (!rangeStartDate) {
				rangeStartDate = [[dateButton date] retain];
				[selectedDates addObject:rangeStartDate];
				[dateButton setSelected:YES];
			} else {
				if ([rangeStartDate isEqualToDate:[dateButton date]]) {
					[rangeStartDate release];
					rangeStartDate = nil;
					[rangeEndDate release];
					rangeEndDate = nil;
					[selectedDates removeAllObjects];
					[dateButton setSelected:NO];
				} else if (rangeEndDate){
					if (rangeStartDate != [dateButton date]) {
						[rangeStartDate release];
					}
					if (rangeEndDate != [dateButton date]) {
						[rangeEndDate release];
					}
					rangeStartDate = [[dateButton date] retain];
					rangeEndDate = nil;
					[selectedDates removeAllObjects];
					[selectedDates addObject:rangeStartDate];
					[dateButton setSelected:YES];
				} else {
					if (rangeEndDate != [dateButton date]) {
						[rangeEndDate release];
					}
					rangeEndDate = [[dateButton date] retain];
					[selectedDates removeAllObjects];
					[selectedDates addObject:rangeEndDate];
					[dateButton setSelected:YES];
					[self addRangeDateObjects];
				}
				[self setUpCalendarWithDate:currentDate];
			}
			
		}
		
		LOG(@"%@", selectedDates);
		if ([delegate respondsToSelector:@selector(picker:didSelectDate:)]) {
			[delegate picker:self didSelectDate:[selectedDates sortedArrayUsingSelector:@selector(compare:)]];
		}
	}
}

- (void)moveLastMonth:(id)sender {
	NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
	[offsetComponents setMonth:-1];
	NSDate *date = [gregorian dateByAddingComponents:offsetComponents toDate:currentDate options:0];
	[self setUpCalendarWithDate:date];
}

- (void)moveNextMonth:(id)sender {
	NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
	[offsetComponents setMonth:1];
	NSDate *date = [gregorian dateByAddingComponents:offsetComponents toDate:currentDate options:0];
	[self setUpCalendarWithDate:date];
}

- (void)setUpCalendarWithDate:(NSDate *)aDate {
	LOG(@"%@", aDate);
	if (currentDate != aDate) {
		[currentDate release];
	}
	currentDate = [aDate retain];
	NSDateComponents *components = [self getDateComponentsFromDate:currentDate];
	[components setDay:1];
	
	NSDate *date = [gregorian dateFromComponents:components];
	components = [self getDateComponentsFromDate:date];
	
	NSDateComponents *minusComponents = [[[NSDateComponents alloc] init] autorelease];
	[minusComponents setDay:-1];
	
	NSDate *lastManthDate = [gregorian dateByAddingComponents:minusComponents toDate:date options:0];
	NSDateComponents *lastManthDateComponents = [self getDateComponentsFromDate:lastManthDate];
	NSUInteger weekday = [lastManthDateComponents weekday];
	while (weekday != 7) {
		NSUInteger day = [lastManthDateComponents day];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * 0) + weekday];
		[self resetButtonAtributes:dateButton];
		
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		
		[dateButton setDate:lastManthDate];
		
		[dateButton setMonthout:YES];
		
		[dateButton setSelected:[selectedDates containsObject:lastManthDate]];
		
		if (minDate != nil
			&& [lastManthDate compare:minDate] != NSOrderedDescending && [lastManthDate compare:minDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		if (maxDate != nil
			&& [lastManthDate compare:maxDate] == NSOrderedDescending && [lastManthDate compare:maxDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		
		[self picker:self buttonForDate:dateButton];
		if ([dataSource respondsToSelector:@selector(picker:buttonForDate:)]) {
			[dataSource picker:self buttonForDate:dateButton];
		}
		
		lastManthDate = [gregorian dateByAddingComponents:minusComponents toDate:lastManthDate options:0];
		lastManthDateComponents = [self getDateComponentsFromDate:lastManthDate];
		weekday = [lastManthDateComponents weekday];
	}
	
	NSDateComponents *plusComponents = [[[NSDateComponents alloc] init] autorelease];
	[plusComponents setDay:1];
	
	//NSInteger year = [components year];
	NSUInteger month = [components month];
	UILabel *monthLabel = (UILabel *)[self viewWithTag:UICCALENDAR_MONTH_LABEL_TAG];
	[monthLabel setText:[self picker:self textForYearMonth:currentDate]];
	if ([dataSource respondsToSelector:@selector(picker:textForYearMonth:)]) {
		[monthLabel setText:[dataSource picker:self textForYearMonth:currentDate]];
	}
	
	NSUInteger weekOfMonth = 0;
	do {
		NSUInteger day = [components day];
		NSUInteger weekday = [components weekday];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * weekOfMonth) + weekday];
		[self resetButtonAtributes:dateButton];
		
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		
		[dateButton setDate:date];
		
		[dateButton setToday:[date isEqualToDate:today]];
		
		[dateButton setDayOfWeek:weekday];
		
		[dateButton setSelected:[selectedDates containsObject:date]];
		
		if (minDate != nil
			&& [date compare:minDate] != NSOrderedDescending && [date compare:minDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		if (maxDate != nil
			&& [date compare:maxDate] == NSOrderedDescending && [date compare:maxDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		
		[self picker:self buttonForDate:dateButton];
		if ([dataSource respondsToSelector:@selector(picker:buttonForDate:)]) {
			[dataSource picker:self buttonForDate:dateButton];
		}
		
		date = [gregorian dateByAddingComponents:plusComponents toDate:date options:0];
		components = [self getDateComponentsFromDate:date];
		
		if (weekday == 7) {
			weekOfMonth++;
		}
	} while (month == [components month]);
	
	weekday = [components weekday];
	while (weekday != 1) {
		NSUInteger day = [components day];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * weekOfMonth) + weekday];
		
		if (weekday == 7) {
			weekOfMonth++;
		}
		
		[self resetButtonAtributes:dateButton];
		
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		
		[dateButton setDate:date];
		
		[dateButton setMonthout:YES];
		
		[dateButton setSelected:[selectedDates containsObject:date]];
		
		if (minDate != nil
			&& [date compare:minDate] != NSOrderedDescending && [date compare:minDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		if (maxDate != nil
			&& [date compare:maxDate] == NSOrderedDescending && [date compare:maxDate] != NSOrderedSame) {
			[dateButton setOutOfRange:YES];
		}
		
		[self picker:self buttonForDate:dateButton];
		if ([dataSource respondsToSelector:@selector(picker:buttonForDate:)]) {
			[dataSource picker:self buttonForDate:dateButton];
		}
		
		date = [gregorian dateByAddingComponents:plusComponents toDate:date options:0];
		
		components = [self getDateComponentsFromDate:date];
		weekday = [components weekday];
	}
	
	for (int i = (7 * weekOfMonth) + weekday; i <= 42; i++) {
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:i];
		[self resetButtonAtributes:dateButton];
		
		[dateButton setTitle:nil forState:UIControlStateNormal];
		[dateButton setDate:nil];
		[self picker:self buttonForDate:dateButton];
		if ([dataSource respondsToSelector:@selector(picker:buttonForDate:)]) {
			[dataSource picker:self buttonForDate:dateButton];
		}
	}
}

- (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date {
	return [gregorian components:(NSDayCalendarUnit | 
								  NSWeekdayCalendarUnit | 
								  NSMonthCalendarUnit |
								  NSYearCalendarUnit) fromDate:date];
}

- (void)addRangeDateObjects {
	NSDateComponents *offsetComponents;
	if ([rangeStartDate compare:rangeEndDate] == NSOrderedAscending) {
		offsetComponents = [[[NSDateComponents alloc] init] autorelease];
		[offsetComponents setDay:1];
	} else if ([rangeStartDate compare:rangeEndDate] == NSOrderedDescending) {
		offsetComponents = [[[NSDateComponents alloc] init] autorelease];
		[offsetComponents setDay:-1];
	} else {
		return;
	}
	
	NSDate *rangeDate = rangeStartDate;
	do {
		[selectedDates addObject:rangeDate];
		rangeDate = [gregorian dateByAddingComponents:offsetComponents toDate:rangeDate options:0];
	} while ([rangeDate compare:rangeEndDate] != NSOrderedSame);
}

@end
