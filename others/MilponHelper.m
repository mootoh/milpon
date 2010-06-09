//
//  MilponHelper.m
//  Milpon
//
//  Created by mootoh on 2/19/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "MilponHelper.h"

static MilponHelper *the_milpon_helper = nil;

@implementation MilponHelper

@synthesize invalidDate;

- (id) init
{
   if (self = [super init]) {
      the_formatter = [[NSDateFormatter alloc] init];
      [the_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
      [the_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [the_formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
      [the_formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];

      invalidDate = [[NSDate dateWithTimeIntervalSince1970:0] retain];
   }
   return self;
}

- (void) dealloc
{
   [invalidDate release];
   [the_formatter release];
   [super dealloc];
}

+ (MilponHelper *) sharedHelper
{
   if (the_milpon_helper == nil) {
      the_milpon_helper = [[MilponHelper alloc] init];
   }
   return the_milpon_helper;
}

- (NSString *) dateToString:(NSDate *) date
{
   NSString *ret = [the_formatter stringFromDate:date];
   return ret;
}

- (NSDate *) stringToDate:(NSString *) str
{
   return [the_formatter dateFromString:str];
}

- (NSString *) dateToRtmString:(NSDate *) date
{
   NSString *ret = [the_formatter stringFromDate:date];
   ret = [ret stringByReplacingOccurrencesOfString:@" " withString:@"T"];
   return [ret stringByAppendingString:@"Z"];
}

- (NSDate *) rtmStringToDate:(NSString *) str
{
   str = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
   str = [str substringToIndex:str.length-1]; // trim last 'Z'
   return [the_formatter dateFromString:str];
}

@end
