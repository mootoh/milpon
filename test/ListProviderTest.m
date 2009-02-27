//
//  ListProviderTest.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ListProvider.h"

@interface ListProviderTest : SenTestCase
{   
}

@end

@implementation ListProviderTest

- (void) testCreate
{
   ListProvider *lp = [ListProvider sharedListProvider];
   NSAssert(lp, @"should not be nil");
}

@end
