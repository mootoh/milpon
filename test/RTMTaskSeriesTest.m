//
//  RTMTaskSeriesTest.m
//  Milpon
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMTaskSeries.h"

@interface RTMTaskSeriesTest : SenTestCase
@end

@implementation RTMTaskSeriesTest

- (void) testAllTasks {
  NSArray *tasks = [RTMTaskSeries allTaskSerieses];
  STAssertTrue(0 < [tasks count], @"tasks should have elements");
	RTMTaskSeries *ts;
	for (ts in tasks) {
		NSLog(@"TaskSeries iD = %d, name=%@", ts.iD, ts.name);
	}
}

@end
