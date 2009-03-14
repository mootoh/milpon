//
//  RTMAuthTest.m
//  Milpon
//
//  Created by mootoh on 10/7/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAuth.h"

@interface RTMAuthTest : SenTestCase; @end

@implementation RTMAuthTest

- (void) setUp
{
}

- (void) tearDown
{
}

- (void) testCreate
{
   RTMAuth *auth = [[[RTMAuth alloc] init] autorelease];
   STAssertNotNil(auth, @"should be created");
}

- (void) testProperties
{
   RTMAuth *auth = [[[RTMAuth alloc] init] autorelease];
   STAssertNotNil(auth.api_key, @"api_key check");
   STAssertNotNil(auth.shared_secret, @"shared_secret check");
   STAssertNotNil(auth.frob, @"frob check");
   STAssertNotNil(auth.token, @"token check");
}
@end
