//
//  RTMList.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Collection.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "LocalCache.h"
#import "TaskProvider.h"

@implementation RTMList

- (id) initByAttribute:(NSDictionary *)attrs
{
   if (self = [super initByAttributes:attrs]) {
   }
   return self;
}


- (void) dealloc
{
   [super dealloc];
}

DEFINE_ATTRIBUTE(name, Name, NSString*, EB_LIST_NAME);

- (NSString *) filter
{
   return [self attribute:@"filter"];
}

- (NSArray *) tasks
{
   return [[TaskProvider sharedTaskProvider] tasksInList:self.iD showCompleted:NO]; // TODO: showCompleted flag should be acquired by global configuration.
}

- (BOOL) isSmart
{
   return self.filter != nil;
}

- (NSInteger) taskCount
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"(to_list_id=%d OR (to_list_id is NULL AND list_id=%d)) AND completed is NULL", self.iD, self.iD] forKey:@"WHERE"];
   NSArray *query = [NSArray arrayWithObject:@"count()"];
   NSArray *counts = [[LocalCache sharedLocalCache] select:query from:@"task" option:cond];
   NSDictionary *count = (NSDictionary *)[counts objectAtIndex:0];
   NSNumber *count_num = [count objectForKey:@"count()"];
   return count_num.integerValue;
}

+ (NSString *) table_name
{
   return @"list";
}

@end // RTMList