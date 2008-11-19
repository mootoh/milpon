//
//  RTMListTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMList.h"
#import "RTMDatabase.h"

@interface RTMListTest : SenTestCase {
   RTMDatabase *db;
}
@end	

@implementation RTMListTest

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
   [RTMList erase:db];

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *vals = [NSArray arrayWithObjects:@"1", @"listOne", nil];
   NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [RTMList create:params inDB:db];
}

- (void) testAllLists
{
   NSArray *lists = [RTMList allLists:db];
   STAssertTrue(0 < [lists count], @"lists should not be empty.");
   NSLog(@"lists count = %d\n", [lists count]);
   STAssertTrue(4 == [lists count], @"lists count should be 4.");
}

#if 0
- (void) testProperty
{
   NSArray *lists = [RTMList allLists:db];
   RTMList *list = [lists objectAtIndex:0];
   STAssertTrue(1 == list.iD, @"check iD");
   STAssertTrue([list.name isEqualToString:@"Inbox"], @"check name");
   STAssertFalse(list.is_smart, @"check smart");
}

- (void) testTasks
{
   NSArray *lists = [RTMList allLists:db];
   RTMList *list = [lists objectAtIndex:0];
   NSArray *tasks = [list tasks];
   STAssertTrue(7 == [tasks count], @"tasks should be 7.");
}
#endif // 0

@end
