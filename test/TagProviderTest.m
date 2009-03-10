//
//  TagProviderTest.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TagProvider.h"

@interface TagProviderTest : SenTestCase; @end

@implementation TagProviderTest

- (void) test00Singleton
{
   TagProvider *tp = [TagProvider sharedTagProvider];
   STAssertNotNil(tp, @"should not be nil");
}

- (void) test01Tags
{
   TagProvider *tp = [TagProvider sharedTagProvider];
   STAssertTrue(tp.tags.count > 0, @"should have some tag elements.");
}

#if 0
- (void) testSync
{
   TagProvider *tp = [TagProvider sharedTagProvider];
   [tp sync];
}
#endif // 0

- (void) testErase
{
   TagProvider *tp = [TagProvider sharedTagProvider];
   [tp erase];
   STAssertEquals(tp.tags.count, 0U, @"tags should be erased to zero.");
}

- (void) testCreate
{
   TagProvider *tp = [TagProvider sharedTagProvider];

   [tp erase];
   int before = tp.tags.count;

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:77], @"lucky seven", nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [tp create:params];

   int after = tp.tags.count;
   STAssertEquals(after, before+1, @"1 element should be added");
}
@end
