#import "UICCalendarPicker.h"
#import "UICCalendarPickerDateButton.h"
#import "UICCalendarPickerDelegate.h"
#import "Debug.h"

#define UICCALENDAR_CONTROL_BUTTON_WIDTH 25.0f
#define UICCALENDAR_CONTROL_BUTTON_HEIGHT 15.0f

#define UICCALENDAR_TITLE_FONT_SIZE 13.0f
#define UICCALENDAR_TITLE_LABEL_WIDTH 140.0f
#define UICCALENDAR_TITLE_LABEL_HEIGHT 15.0f
#define UICCALENDAR_TITLE_LABEL_TAG 100

#define UICCALENDAR_CELL_FONT_SIZE 13.0f
#define UICCALENDAR_CELL_WIDTH 27.0f
#define UICCALENDAR_CELL_HEIGHT 24.0f

@interface UICCalendarPicker(Private)
- (void)moveLastMonth:(id)sender;
- (void)moveNextMonth:(id)sender;
- (void)setUpCalendarWithDate:(NSDate *)aDate;
- (void)addRangeDateObjects;
- (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date;
@end

@implementation UICCalendarPicker

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

@synthesize delegate;

@synthesize style;
@synthesize selectionMode;

@synthesize pageDate;

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
	if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 204.0f, 234.0f)]) {
		[self setImage:[UIImage imageNamed:@"uiccalendar_background.png"]];
		[self setUserInteractionEnabled:YES];

		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_close.png"] forState:UIControlStateNormal];
		[closeButton setFrame:CGRectMake(173.0f, 6.0f, UICCALENDAR_CONTROL_BUTTON_WIDTH, UICCALENDAR_CONTROL_BUTTON_HEIGHT)];
		[closeButton setShowsTouchWhenHighlighted:NO];
		[closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];
		
		UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[prevButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_left_arrow.png"] forState:UIControlStateNormal];
		[prevButton setFrame:CGRectMake(6.0f, 36.0f, UICCALENDAR_CONTROL_BUTTON_WIDTH, UICCALENDAR_CONTROL_BUTTON_HEIGHT)];
		[prevButton setShowsTouchWhenHighlighted:NO];
		[prevButton addTarget:self action:@selector(moveLastMonth:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:prevButton];
		
		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"uiccalendar_right_arrow.png"] forState:UIControlStateNormal];
		[nextButton setFrame:CGRectMake(173.0f, 36.0f, UICCALENDAR_CONTROL_BUTTON_WIDTH, UICCALENDAR_CONTROL_BUTTON_HEIGHT)];
		[nextButton setShowsTouchWhenHighlighted:NO];
		[nextButton addTarget:self action:@selector(moveNextMonth:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nextButton];
		
		UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[monthLabel setTag:UICCALENDAR_TITLE_LABEL_TAG];
		[monthLabel setBackgroundColor:[UIColor clearColor]];
		[monthLabel setTextColor:[UIColor blackColor]];
		[monthLabel setTextAlignment:UITextAlignmentCenter];
		[monthLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:UICCALENDAR_TITLE_FONT_SIZE]];
		[monthLabel setFrame:CGRectMake(self.frame.size.width / 2 - UICCALENDAR_TITLE_LABEL_WIDTH / 2, 36.0f, UICCALENDAR_TITLE_LABEL_WIDTH, UICCALENDAR_TITLE_LABEL_HEIGHT)];
		[self addSubview:monthLabel];
		[monthLabel release];
		
		for (int i = 0; i < 42; i++) {
			UICCalendarPickerDateButton *dateButton = [[UICCalendarPickerDateButton alloc] init];
			[dateButton setTag:i + 1];
			[dateButton setBackgroundImage:normalCell forState:UIControlStateNormal];
			[dateButton setBackgroundImage:selectedCell forState:UIControlStateSelected];
			[dateButton setBackgroundImage:disabledCell forState:UIControlStateDisabled];
			[dateButton setTitleColor:normalColor forState:UIControlStateNormal];
			[dateButton setTitleColor:selectedColor forState:UIControlStateSelected];
			[dateButton setTitleColor:disabledColor forState:UIControlStateDisabled];
			[dateButton setFont:[UIFont fontWithName:@"ArialMT" size:UICCALENDAR_CELL_FONT_SIZE]];
			[dateButton setFrame:CGRectMake(11.0f + UICCALENDAR_CELL_WIDTH * (i % 7) - (i % 7), 84.0f + UICCALENDAR_CELL_HEIGHT * (i / 7) - (i / 7), UICCALENDAR_CELL_WIDTH, UICCALENDAR_CELL_HEIGHT)];
			[dateButton setShowsTouchWhenHighlighted:NO];
			[dateButton addTarget:self action:@selector(dateButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
			
			[self addSubview:dateButton];
			[dateButton release];
		}
		
		self.selectedDates = [NSMutableArray array];
		
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		dateFormatter = [[NSDateFormatter alloc] init];
		
		today = [NSDate date];
		NSDateComponents *todayComponents = [self getDateComponentsFromDate:today];
		today = [[gregorian dateFromComponents:todayComponents] retain];
		
		self.pageDate = today;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		;
    }
    return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[dateFormatter release];
	[gregorian release];
	[maxDate release];
	[minDate release];
	[selectedDates release];
	[today release];
	[currentDate release];
	[pageDate release];
	[delegate release];
    [super dealloc];
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

- (void)showInView:(UIView *)aView {
	[self setCenter:CGPointMake(aView.frame.size.width / 2, self.frame.size.height / 2)];
	[self setUpCalendarWithDate:pageDate];
	
	/*if (style == UICCalendarPickerStyleDefault) {
		[self setBackgroundColor:[UIColor darkGrayColor]];
	} else if (style == UICCalendarPickerStyleBlackOpaque) {
		[self setBackgroundColor:[UIColor blackColor]];
	} else {
		[self setBackgroundColor:[UIColor blackColor]];
		[self setAlpha:0.8f];
	}*/

	[aView addSubview:self];
}

- (void)dismiss:(id)sender {
	[self removeFromSuperview];
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
					[selectedDates removeAllObjects];
					[dateButton setSelected:NO];
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
	currentDate = [aDate retain];;
	NSDateComponents *components = [self getDateComponentsFromDate:currentDate];
	[components setDay:1];
	
	NSDate *date = [gregorian dateFromComponents:components];
	components = [self getDateComponentsFromDate:date];
	
	NSDateComponents *minusComponents = [[[NSDateComponents alloc] init] autorelease];
	[minusComponents setDay:-1];
	
	NSDate *lastManthDate = [gregorian dateByAddingComponents:minusComponents toDate:date options:0];
	NSDateComponents *lastManthDateComponents = [self getDateComponentsFromDate:lastManthDate];
	NSInteger weekday = [lastManthDateComponents weekday];
	while (weekday != 7) {
		NSInteger day = [lastManthDateComponents day];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * 0) + weekday];
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		[dateButton setBackgroundImage:monthoutCell forState:UIControlStateNormal];
		[dateButton setTitleColor:monthoutColor forState:UIControlStateNormal];
		
		if ([selectedDates containsObject:lastManthDate]) {
			[dateButton setSelected:YES];
		} else {
			[dateButton setSelected:NO];
		}
		
		[dateButton setEnabled:YES];
		if (minDate != nil
			&& [lastManthDate compare:minDate] != NSOrderedDescending && [lastManthDate compare:minDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		if (maxDate != nil
			&& [lastManthDate compare:maxDate] != NSOrderedAscending && [lastManthDate compare:maxDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		
		[dateButton setDate:lastManthDate];
		
		lastManthDate = [gregorian dateByAddingComponents:minusComponents toDate:lastManthDate options:0];
		lastManthDateComponents = [self getDateComponentsFromDate:lastManthDate];
		weekday = [lastManthDateComponents weekday];
	}
	
	NSDateComponents *plusComponents = [[[NSDateComponents alloc] init] autorelease];
	[plusComponents setDay:1];
	
	//NSInteger year = [components year];
	NSInteger month = [components month];
	UILabel *monthLabel = (UILabel *)[self viewWithTag:UICCALENDAR_TITLE_LABEL_TAG];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[dateFormatter setDateFormat:@"MMMM yyyy"];
	[monthLabel setText:[dateFormatter stringFromDate:date]];
	
	NSInteger weekOfMonth = 0;
	do {
		NSInteger day = [components day];
		NSInteger weekday = [components weekday];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * weekOfMonth) + weekday];
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		
		if (weekday == 1) {
			[dateButton setBackgroundImage:holidayCell forState:UIControlStateNormal];
			[dateButton setTitleColor:holidayColor forState:UIControlStateNormal];
		} else {
			[dateButton setBackgroundImage:normalCell forState:UIControlStateNormal];
			[dateButton setTitleColor:normalColor forState:UIControlStateNormal];
		}
		
		if ([date isEqualToDate:today]) {
			[dateButton setBackgroundImage:todayCell forState:UIControlStateNormal];
		}
		
		if ([selectedDates containsObject:date]) {
			if ([date isEqualToDate:today]) {
				[dateButton setBackgroundImage:todaySelectedCell forState:UIControlStateSelected];
			} else {
				[dateButton setBackgroundImage:selectedCell forState:UIControlStateSelected];
			}
			[dateButton setSelected:YES];
		} else {
			[dateButton setSelected:NO];
		}
		
		[dateButton setEnabled:YES];
		if (minDate != nil
			&& [date compare:minDate] != NSOrderedDescending && [date compare:minDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		if (maxDate != nil
			&& [date compare:maxDate] == NSOrderedDescending && [date compare:maxDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		
		[dateButton setDate:date];
		
		date = [gregorian dateByAddingComponents:plusComponents toDate:date options:0];
		components = [self getDateComponentsFromDate:date];
		
		if (weekday == 7) {
			weekOfMonth++;
		}
	} while (month == [components month]);
	
	weekday = [components weekday];
	while (weekday != 1) {
		NSInteger day = [components day];
		
		UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:(7 * weekOfMonth) + weekday];
		[dateButton setTitle:[NSString stringWithFormat:@"%d", day] forState:UIControlStateNormal];
		[dateButton setBackgroundImage:monthoutCell forState:UIControlStateNormal];
		[dateButton setTitleColor:monthoutColor forState:UIControlStateNormal];
		
		if ([selectedDates containsObject:date]) {
			[dateButton setSelected:YES];
		} else {
			[dateButton setSelected:NO];
		}
		
		[dateButton setEnabled:YES];
		if (minDate != nil
			&& [date compare:minDate] != NSOrderedDescending && [date compare:minDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		if (maxDate != nil
			&& [date compare:maxDate] == NSOrderedDescending && [date compare:maxDate] != NSOrderedSame) {
			[dateButton setEnabled:NO];
		}
		
		[dateButton setDate:date];
		
		date = [gregorian dateByAddingComponents:plusComponents toDate:date options:0];
		
		components = [self getDateComponentsFromDate:date];
		weekday = [components weekday];
	}
	
	if (weekOfMonth == 4) {
		for (int i = 35 + weekday; i <= 42; i++) {
			UICCalendarPickerDateButton *dateButton = (UICCalendarPickerDateButton *)[self viewWithTag:i];
			[dateButton setTitle:nil forState:UIControlStateNormal];
			[dateButton setSelected:NO];
			[dateButton setEnabled:NO];
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

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

@end
