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

- (id) init
{
   if (self = [super init]) {
      the_formatter = [[NSDateFormatter alloc] init];
      [the_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
      [the_formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
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
   ret = [ret stringByReplacingOccurrencesOfString:@"_" withString:@" "];
   return ret; // [ret stringByAppendingString:@"Z"];
}

@end
