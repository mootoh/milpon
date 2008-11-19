//
//  RTMAuthTest.m
//  Milpon
//
//  Created by mootoh on 10/7/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAuth.h"
#import "RTMDatabase.h"

@interface RTMAuthTest : SenTestCase {
   RTMDatabase *db;
}
@end

@implementation RTMAuthTest

- (void) setUp
{
   db = [[RTMDatabase alloc] init];
}

- (void) tearDown
{
   [db release];
}

- (void) testCreate
{
   RTMAuth *auth = [[[RTMAuth alloc] init] autorelease];
   STAssertNotNil(auth, @"should be created");
}

- (void) testProperties
{
   RTMAuth *auth = [[[RTMAuth alloc] initWithDB:db] autorelease];
   STAssertNotNil(auth.api_key, @"api_key check");
   STAssertNotNil(auth.shared_secret, @"shared_secret check");
   STAssertNotNil(auth.frob, @"frob check");
   STAssertNotNil(auth.token, @"token check");
   STAssertNotNil(auth.name, @"name check");
}
@end
