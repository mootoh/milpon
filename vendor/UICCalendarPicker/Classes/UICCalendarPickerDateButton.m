#import "UICCalendarPickerDateButton.h"
#import "Debug.h"

@implementation UICCalendarPickerDateButton

@synthesize date;
@synthesize button;

- (id)init {
	if (self = [super init]) {
		self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	}
	return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
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
