//
//  RTMNote.m
//  Milpon
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMNote.h"

@implementation RTMNote

@synthesize iD, modified, created, title, body, task_id;

- (id) init:(NSInteger)i created:(NSString *)c modified:(NSString *)m title:(NSString *)t task_id:(NSInteger)tid
{
	if (self = [super init]) {
    self.iD = i;
    self.created = c;
    self.modified = m;
    self.title = t;
    self.task_id = tid;
	}
	return self;
}

@end
