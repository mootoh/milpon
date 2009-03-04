//
//  LocalCache.m
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LocalCache.h"

@interface LocalCacheTest : SenTestCase; @end

@implementation LocalCacheTest

- (void) testSingleton
{
   LocalCache *local_cache = (LocalCache *)[LocalCache sharedLocalCache];
   STAssertNotNil(local_cache, @"instance should not be nil");
}

- (void) testSelect
{
   LocalCache *db = (LocalCache *)[LocalCache sharedLocalCache];
   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];
   NSArray *results = [db select:dict from:@"task"];
   NSDictionary *result = [results objectAtIndex:0];
   STAssertEquals([NSNumber numberWithInt:1], [result objectForKey:@"id"], @"id check");
   STAssertTrue([[result objectForKey:@"name"] isEqualToString:@"task one"], @"name check");
}

- (void) testInsert
{
   LocalCache *db = (LocalCache *)[LocalCache sharedLocalCache];
   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber numberWithInt:7], @"some name", nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];
   [db insert:dict into:@"task"];
}

- (void) testUpdate
{
   LocalCache *db = (LocalCache *)[LocalCache sharedLocalCache];
   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber numberWithInt:3], @"updated name", nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];
   [db update:dict table:@"task" condition:@"WHERE id=1"];
}

- (void) testDelete
{
   LocalCache *db = (LocalCache *)[LocalCache sharedLocalCache];
   [db delete:@"task" condition:@"WHERE id=2"];
}

@end
