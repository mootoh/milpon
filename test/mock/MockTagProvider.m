//
//  MockTagProvider.m
//  Milpon
//
//  Created by mootoh on 1/28/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "MockTagProvider.h"

@implementation MockTagProvider

- (id) init
{
   if (self = [super init]) {
      fixed_tags = [[NSArray arrayWithObjects:@"housekeeping", @"doing", nil] retain];
   }
   return self;
}

- (NSArray *) tags
{
   return fixed_tags;
}

- (void) dealloc
{
   [fixed_tags release];
   [super dealloc];
}

@end
