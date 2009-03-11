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
#import "RTMTag.h"
#import "LocalCache.h"
#import "logger.h"

@implementation DBTaskProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      dirty_ = NO;
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

   NSArray *keys = [NSArray arrayWithObjects:
      @"task.id", @"task.edit_bits",
      @"task.task_id", @"task.due", @"task.completed", @"task.priority", @"task.postponed", @"task.estimate", @"task.has_due_time",
      @"task.taskseries_id", @"task.name", @"task.url", @"task.location_id", @"task.list_id", @"task.rrule", nil];
   NSArray *types = [NSArray arrayWithObjects:
      [NSNumber class], [NSNumber class],
      [NSNumber class], [NSDate class], [NSDate class], [NSNumber class], [NSNumber class], [NSString class],[NSNumber class], 
      [NSNumber class], [NSString class], [NSString class], [NSNumber class], [NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];

   NSArray *task_arr = conditions ?
      [local_cache_ select:dict from:@"task" option:conditions] : 
      [local_cache_ select:dict from:@"task"];

   for (NSDictionary *dict in task_arr) {
      RTMTask *task = [[[RTMTask alloc] initByParams:dict] autorelease];

      int tid = ([task.edit_bits intValue] & EB_CREATED_OFFLINE) ?
         [task.iD intValue] :
         [task.taskseries_id intValue];

      { // collect tags
         NSDictionary *tag_dict = [NSDictionary dictionaryWithObject:[NSString class] forKey:@"name"];
         NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
         NSArray *join_vals = [NSArray arrayWithObjects:@"task_tag", @"tag.id=task_tag.tag_id", nil];
         NSDictionary *join_dict = [NSDictionary dictionaryWithObjects:join_vals forKeys:join_keys];

         NSArray *tag_keys = [NSArray arrayWithObjects:@"WHERE", @"JOIN", nil];
         NSArray *tag_vals = [NSArray arrayWithObjects:
            [NSString stringWithFormat:@"task_tag.task_id=%d", tid],
            join_dict,
            nil];
         NSDictionary *tag_opts = [NSDictionary dictionaryWithObjects:tag_vals forKeys:tag_keys];

         NSArray *tags_dict = [local_cache_ select:tag_dict from:@"tag" option:tag_opts];
         NSMutableArray *tags = [NSMutableArray array];
         for (NSDictionary *tag in tags_dict)
            [tags addObject:[tag objectForKey:@"name"]];
         task.tags = tags;
      }
      { // collect notes
         NSArray *note_keys = [NSArray arrayWithObjects:@"title", @"text", nil];
         NSArray *note_vals = [NSArray arrayWithObjects:[NSString class], [NSString class], nil];
         NSDictionary *note_dict = [NSDictionary dictionaryWithObjects:note_vals forKeys:note_keys];

         NSDictionary *note_opts = [NSDictionary dictionaryWithObject:
            [NSString stringWithFormat:@"task_id=%d", tid] forKey:@"WHERE"];

         NSArray *notes = [local_cache_ select:note_dict from:@"note" option:note_opts];
         task.notes = notes;
      }

      [tasks addObject:task];
   }

   [pool release];
   return tasks;
}

- (NSArray *) tasks
{
   return [self tasks:nil];
}

- (NSArray *) tasksInList:(RTMList *)list
{
   NSArray *keys = [NSArray arrayWithObjects:@"WHERE", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"list_id=%d", [list.iD intValue]],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (NSArray *) tasksInTag:(RTMTag *)tag
{
   NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
   NSArray *join_vals = [NSArray arrayWithObjects:@"task_tag", @"(task.taskseries_id IS NULL AND task.id=task_tag.task_id) OR (task.taskseries_id IS NOT NULL AND task.taskseries_id=task_tag.task_id)", nil];
   NSArray *keys = [NSArray arrayWithObjects:@"WHERE", @"ORDER", @"JOIN", @"GROUP", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"task_tag.tag_id=%d", [tag.iD intValue]],
      [NSString stringWithFormat:@"task.priority=0 ASC, task.priority ASC, task.due IS NULL ASC, task.due ASC"],
      [NSDictionary dictionaryWithObjects:join_vals forKeys:join_keys],
      @"task_tag.task_id",
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (NSArray *) existingTasks
{
   NSArray *keys = [NSArray arrayWithObjects:@"where", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"completed='' OR completed is NULL"],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (void) complete:(RTMTask *)task
{
   [task flagUpEditBits:EB_TASK_COMPLETED];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:@"1" forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
}

- (void) uncomplete:(RTMTask *)task
{
   [task flagUpEditBits:EB_TASK_COMPLETED];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:@"" forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
}

- (NSNumber *) createAtOffline:(NSDictionary *)params
{
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:params];
   NSNumber *edit_bits = [NSNumber numberWithInt:EB_CREATED_OFFLINE];
   [attrs setObject:edit_bits forKey:@"edit_bits"];

   [local_cache_ insert:attrs into:@"task"];
   dirty_ = YES;

   NSDictionary *iid = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"id"];
   NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
   NSArray *ret = [local_cache_ select:iid from:@"task" option:order];
   NSNumber *retn = [[ret objectAtIndex:0] objectForKey:@"id"];
   NSLog(@"retn = %d", [retn intValue]);
   return retn;
}

- (void) createAtOnline:(NSDictionary *)params
{
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:params];
   NSNumber *edit_bits = [NSNumber numberWithInt:0];
   [attrs setObject:edit_bits forKey:@"edit_bits"];
   [attrs setObject:[params objectForKey:@"id"] forKey:@"taskseries_id"];

   [attrs removeObjectForKey:@"created"];
   [attrs removeObjectForKey:@"modified"];
   [attrs removeObjectForKey:@"source"];

   NSArray *tasks = [attrs objectForKey:@"tasks"];
   //NSArray *notes = [attrs objectForKey:@"notes"]; // TODO: enable this
   //NSArray *tags = [attrs objectForKey:@"tags"]; // TODO: enable this

   [attrs removeObjectForKey:@"tasks"];
   [attrs removeObjectForKey:@"notes"];
   [attrs removeObjectForKey:@"tags"];

   for (NSDictionary *task in tasks) {
      // TODO: setup correctly
      NSMutableDictionary *task_attrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
      [task_attrs setObject:[task objectForKey:@"id"] forKey:@"id"];
      [task_attrs setObject:[task objectForKey:@"due"] forKey:@"due"];
      [task_attrs setObject:[task objectForKey:@"completed"] forKey:@"completed"];
      [task_attrs setObject:[task objectForKey:@"deleted"] forKey:@"deleted"];
      [task_attrs setObject:[task objectForKey:@"priority"] forKey:@"priority"];
      [task_attrs setObject:[task objectForKey:@"priority"] forKey:@"priority"];
      [task_attrs setObject:[task objectForKey:@"postponed"] forKey:@"postponed"];
      [task_attrs setObject:[task objectForKey:@"estimate"] forKey:@"estimate"];

      [local_cache_ insert:task_attrs into:@"task"];
   }
   dirty_ = YES;
}

- (void) remove:(RTMTask *) task
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@", [[task iD] stringValue]];
   [local_cache_ delete:@"task" condition:cond];
   dirty_ = YES;
}

- (void) erase
{
   [local_cache_ delete:@"task" condition:nil];
   [local_cache_ delete:@"note" condition:nil];
   [local_cache_ delete:@"tag" condition:nil];
   [local_cache_ delete:@"location" condition:nil];
   dirty_ = YES;
}

- (void) createNote:(NSString *)note task_id:(NSNumber *)tid
{
   NSArray *keys = [NSArray arrayWithObjects:@"text", @"task_id", @"edit_bits", nil];
   NSArray *vals = [NSArray arrayWithObjects:note, tid, [NSNumber numberWithInt:EB_CREATED_OFFLINE], nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
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
