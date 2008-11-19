//
//  RTMDatabaseTest.m
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMDatabase.h"

@interface RTMDatabaseTest : SenTestCase
@end

@implementation RTMDatabaseTest

- (void) testSingleton
{
   RTMDatabase *db_wrapper = [[[RTMDatabase alloc] init] autorelease];
   STAssertNotNil(db_wrapper, @"singleton instance should not be nil");
}

- (void) testPath
{
   RTMDatabase *db = [[[RTMDatabase alloc] init] autorelease];
   NSString *path = [db path];
   NSLog(@"db path = %@", path);
   STAssertTrue([path isEqualToString:@"/tmp/rtm.sql"], @"check path");
}

@end
