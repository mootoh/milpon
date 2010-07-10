//
//  MPTask.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTask.h"

@implementation MPTask

static NSDate *s_completed_default_date = nil;

+ (NSDate *) completedDefaultDate
{
   if (! s_completed_default_date)
      s_completed_default_date = [[NSDate dateWithTimeIntervalSince1970:0] retain];
   return s_completed_default_date;
}

- (NSString *) is_completed
{
   [self willAccessValueForKey:@"is_completed"];
   NSDate *d = [self valueForKey:@"completed"];
   [self didAccessValueForKey:@"is_completed"];
   return (d && ![d isEqualToDate:[MPTask completedDefaultDate]]) ? @"Completed" : nil;
}

- (void) complete
{
   NSDate *d = [self valueForKey:@"completed"];
   if (d && ![d isEqualToDate:[MPTask completedDefaultDate]]) return;
   [self setValue:[NSDate date] forKey:@"completed"];
   NSInteger edit_bits = [[self valueForKey:@"edit_bits"] integerValue];
   edit_bits |= EDIT_BITS_TASK_COMPLETION;
   [self setValue:[NSNumber numberWithInteger:edit_bits] forKey:@"edit_bits"];
}

- (void) uncomplete
{
   NSDate *d = [self valueForKey:@"completed"];
   if (!d || [d isEqualToDate:[MPTask completedDefaultDate]]) return;
   [self setValue:[MPTask completedDefaultDate] forKey:@"completed"];
   NSInteger edit_bits = [[self valueForKey:@"edit_bits"] integerValue];
   edit_bits |= EDIT_BITS_TASK_COMPLETION;
   [self setValue:[NSNumber numberWithInteger:edit_bits] forKey:@"edit_bits"];
}

@end