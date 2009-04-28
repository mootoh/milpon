//
//  RTMListTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMList.h"

@interface RTMListTest : SenTestCase; @end	

@implementation RTMListTest

- (void) testCreate
{
   NSArray *keys = [NSArray arrayWithObjects:@"list.id", @"list.name", @"list.filter", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], @"list One", @"", nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   RTMList *list = [[RTMList alloc] initByAttributes:attrs];
   STAssertNotNil(list, @"list should be created");
}

#if 0
- (void) testTasks
{
   RTMList *list = [[RTMList alloc]
      initWithID:[NSNumber numberWithInt:1]
      forName:@"list one"];

   NSArray *tasks = list.tasks;
   STAssertEquals([tasks count], 3U, @"tasks should be 7.");
}
#endif // 0
@end
