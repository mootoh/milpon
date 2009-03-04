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

@interface RTMListTest : SenTestCase
@end	

@implementation RTMListTest

- (void) testCreate
{
   RTMList *list = [[RTMList alloc]
      initWithID:[NSNumber numberWithInt:1]
      forName:@"list one"];
   STAssertNotNil(list, @"list should be created");
}

- (void) testTasks
{
   RTMList *list = [[RTMList alloc]
      initWithID:[NSNumber numberWithInt:1]
      forName:@"list one"];

   NSArray *tasks = list.tasks;
   STAssertEquals([tasks count], 3U, @"tasks should be 7.");
}

@end
