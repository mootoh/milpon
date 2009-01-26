//
//  TrialListProvider.m
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TrialListProvider.h"


@implementation TrialListProvider

- (id) init
{
   if (self = [super init]) {
      fixed_lists = [[NSArray arrayWithObjects:@"Inbox", @"Action", @"Project", nil] retain];
   }
   return self;
}

- (void) dealloc
{
   [fixed_lists release];
   [super dealloc];
}

- (NSArray *) lists
{
   return fixed_lists;
}

@end
