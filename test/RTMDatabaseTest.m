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
   RTMDatabase *db = (RTMDatabase *)[RTMDatabase sharedDatabase];
   STAssertNotNil(db, @"instance should not be nil");
}

- (void) testPath
{
   RTMDatabase *db = (RTMDatabase *)[RTMDatabase sharedDatabase];
   NSString *path = [db path];
   STAssertTrue([path isEqualToString:@"/tmp/rtm.sql"], @"check path");
}

- (void) testSelect
{
   RTMDatabase *db = (RTMDatabase *)[RTMDatabase sharedDatabase];
   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];
   NSArray *results = [db select:dict from:@"task"];
   NSDictionary *result = [results objectAtIndex:0];
   STAssertEquals([NSNumber numberWithInt:1], [result objectForKey:@"id"], @"id check");
   STAssertTrue([[result objectForKey:@"name"] isEqualToString:@"task one"], @"name check");
}

@end
