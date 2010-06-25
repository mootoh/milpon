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
   NSDate *c = [self completed];
   [self didAccessValueForKey:@"is_completed"];
   return c == nil ? nil : @"Completed";
}

@end