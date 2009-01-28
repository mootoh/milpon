//
//  TrialTagProvider.m
//  Milpon
//
//  Created by mootoh on 1/28/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TrialTagProvider.h"


@implementation TrialTagProvider

- (id) init
{
   if (self = [super init]) {
      fixed_tags = [[NSSet setWithObjects:@"housekeeping", @"doing", nil] retain];
   }
   return self;
}

- (NSSet *) tags
{
   return fixed_tags;
}

- (void) dealloc
{
   [fixed_tags release];
   [super dealloc];
}

@end
