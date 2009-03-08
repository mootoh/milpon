//
//  DBTaskProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBTaskProvider.h"
#import "RTMTask.h"
#import "RTMList.h"
#import "LocalCache.h"

@implementation DBTaskProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      dirty_ = NO;
      //tasks_ = [self tasks];
   }
   return self;
}

- (void) dealloc
{
   [tasks_ release];
   [super dealloc];
}

- (NSArray *) tasks:(NSDictionary *)conditions
{
   NSMutableArray *tasks = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"priority",
      @"postponed", @"estimate", @"rrule", @"location_id", @"list_id",
      @"task_series_id", @"edit_bits", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], [NSString class], [NSString class],
     [NSNumber class], [NSNumber class], [NSString class], [NSString class],
     [NSNumber class], [NSNumber class], [NSNumber class], [NSNumber class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];

   NSArray *task_arr = conditions ?
      [local_cache_ select:dict from:@"task" option:conditions] : 
      [local_cache_ select:dict from:@"task"];

   for (NSDictionary *dict in task_arr) {
      RTMTask *task = [[[RTMTask alloc] initByParams:dict] autorelease];
      [tasks addObject:task];
   }

   [pool release];
   return tasks;
#if 0
      " from task where completed='' OR completed is NULL"
      " ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC"];
   return [RTMTask tasksForSQL:sql inDB:db];
#endif // 0
}

- (NSArray *) tasks
{
   return [self tasks:nil];
}

- (NSArray *) tasksInList:(RTMList *)list
{
   NSArray *keys = [NSArray arrayWithObjects:@"where", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"list_id=%d", [list.iD intValue]],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

#if 0
      "where list_id=%d AND (completed='' OR completed is NULL) "
      "ORDER BY priority=0 ASC,priority ASC, due IS NULL ASC, due ASC",
#endif // 0

   return [self tasks:cond];
}

- (void) complete:(RTMTask *)task
{
   [task flagUpEditBits:EB_TASK_COMPLETED];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:@"1" forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
}

- (void) createAtOffline:(NSDictionary *)params
{
   NSNumber *edit_bits = [NSNumber numberWithInt:EB_CREATED_OFFLINE];
   NSArray *keys = [NSArray arrayWithObjects:@"name", @"edit_bits",  nil];
   NSArray *vals = [NSArray arrayWithObjects:[params objectForKey:@"name"], edit_bits, nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [local_cache_ insert:attrs into:@"task"];
   dirty_ = YES;
}

- (void) remove:(RTMTask *) task
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@",
      [[task iD] stringValue]];
   [local_cache_ delete:@"task" condition:cond];
   dirty_ = YES;
}

@end // DBTaskProvider

@implementation TaskProvider (DB) // {{{

static DBTaskProvider *s_db_list_provider = nil;

+ (TaskProvider *) sharedTaskProvider
{
   if (nil == s_db_list_provider)
      s_db_list_provider = [[DBTaskProvider alloc] init];
   return s_db_list_provider; 
}

@end // TaskProvider (DB) // }}}
