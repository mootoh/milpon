//
//  MPTask.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPTask.h"

@implementation MPTask

- (NSString *) is_completed
{
   [self willAccessValueForKey:@"is_completed"];
   NSDate *c = [self valueForKey:@"completed"];
   [self didAccessValueForKey:@"is_completed"];
   return c == nil ? nil : @"Completed";
}

- (void) complete
{
   if ([self valueForKey:@"completed"]) return;
   [self setValue:[NSDate date] forKey:@"completed"];
   NSInteger edit_bits = [[self valueForKey:@"edit_bits"] integerValue];
   edit_bits |= EDIT_BITS_TASK_COMPLETION;
   [self setValue:[NSNumber numberWithInteger:edit_bits] forKey:@"edit_bits"];
}

@end