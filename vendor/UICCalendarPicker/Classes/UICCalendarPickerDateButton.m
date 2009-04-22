#import "UICCalendarPickerDateButton.h"
#import "Debug.h"

@implementation UICCalendarPickerDateButton

@synthesize date;
@synthesize dayOfWeek;
@synthesize monthout;
@synthesize outOfRange;

- (BOOL)isToday {
	return isToday;
}

- (void)setToday:(BOOL)b {
	isToday = b;
}

- (id)init {
	if (self = [super init]) {
		button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		date = nil;
		isToday = NO;
		dayOfWeek = UICCalendarPickerDayOfWeekSunday;
		outOfRange = NO;
	}
	return self;
}

- (void)dealloc {
	[date release];
	[button release];
	[super dealloc];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
	if ([button respondsToSelector:[anInvocation selector]]) {
		[anInvocation invokeWithTarget:button];
	}
	else {
		[super forwardInvocation:anInvocation];
	}
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
	NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
	if (signature == nil) {
		signature = [button methodSignatureForSelector:aSelector];
	}
	return signature;
}

@end
