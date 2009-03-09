//
//  MilponHelper.m
//  Milpon
//
//  Created by mootoh on 2/19/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "MilponHelper.h"

static MilponHelper *the_milpon_helper;

@implementation MilponHelper

@synthesize invalidDate;

- (id) init
{
   if (self = [super init]) {
      the_formatter = [[NSDateFormatter alloc] init];
      [the_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
      [the_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      invalidDate = [NSDate dateWithTimeIntervalSince1970:0];
   }
   return self;
}

- (void) dealloc
{
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
   //ret = [ret stringByReplacingOccurrencesOfString:@"_" withString:@" "];
   return ret; // [ret stringByAppendingString:@"Z"];
}

- (NSDate *) stringToDate:(NSString *) str
{
   NSDate *ret = [the_formatter dateFromString:str];
   return ret;
}

@end
