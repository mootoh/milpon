//
//  DBTaskProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBTaskProvider.h"
#import "RTMTask.h"
#import "Collection.h"
#import "RTMTag.h"
#import "RTMNote.h"
#import "LocalCache.h"
#import "logger.h"
#import "MilponHelper.h"
#import "TagProvider.h"
#import "NoteProvider.h"

@interface DBTaskProvider (Private)
- (BOOL) taskExist:(NSNumber *)task_id;
- (void) removeForID:(NSNumber *) task_id;
- (void) updateTask:(NSDictionary *)taskseries;
- (BOOL) taskseriesExist:(NSNumber *)taskseries_id;
- (void) removeForTaskseries:(NSNumber *) taskseries_id;
- (RTMTask *) taskForTaskID:(NSInteger) task_id;
@end

@implementation DBTaskProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (NSArray *) tasksWithCondition:(NSDictionary *)conditions
{
   NSMutableArray *tasks = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys = [NSArray arrayWithObjects:
      @"task.id", @"task.edit_bits",
      @"task.task_id", @"task.due", @"task.completed", @"task.priority", @"task.postponed", @"task.estimate", @"task.has_due_time",
      @"task.taskseries_id", @"task.name", @"task.url", @"task.location_id", @"task.list_id", @"task.rrule", @"task.to_list_id", nil];

   NSArray *task_arr = conditions ?
      [local_cache_ select:keys from:@"task" option:conditions] : 
      [local_cache_ select:keys from:@"task"];

   for (NSDictionary *dict in task_arr) {
      RTMTask *task = [[RTMTask alloc] initByAttributes:dict];
      [tasks addObject:task];
      [task release];
   }

   [pool release];
   return tasks;
}

- (NSArray *) tasks:(BOOL) showCompleted
{
   NSMutableDictionary *cond = [NSMutableDictionary dictionaryWithObject:@"ORDER" forKey:@"priority ASC, due IS NULL ASC, due ASC"];
   if (! showCompleted)
      [cond setObject:@"completed IS NULL" forKey:@"WHERE"];
   return [self tasksWithCondition:cond];
}

- (NSArray *) tasksInList:(NSInteger) list_id showCompleted:(BOOL) sc
{
   NSString *where = [NSString stringWithFormat:@"(to_list_id=%d OR (to_list_id is NULL AND list_id=%d))", list_id, list_id];
   if (! sc)
      where = [where stringByAppendingString:@" AND completed IS NULL"];

   NSArray *keys = [NSArray arrayWithObjects:@"WHERE", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:where,
      [NSString stringWithFormat:@"priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSMutableDictionary *cond = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasksWithCondition:cond];
}

- (NSArray *) tasksInTag: (NSInteger) tag_id showCompleted:(BOOL) sc
{
   NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
   NSArray *join_vals = [NSArray arrayWithObjects:@"task_tag", @"task.id=task_tag.task_id", nil];

   NSString *where = [NSString stringWithFormat:@"task_tag.tag_id=%d", tag_id];
   if (! sc)
      where = [where stringByAppendingString:@" AND completed IS NULL"];

   NSArray *keys = [NSArray arrayWithObjects:@"WHERE", @"ORDER", @"JOIN", @"GROUP", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      where,
      [NSString stringWithFormat:@"task.priority ASC, task.due IS NULL ASC, task.due ASC"],
      [NSDictionary dictionaryWithObjects:join_vals forKeys:join_keys],
      @"task_tag.task_id",
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasksWithCondition:cond];
}

- (NSArray *) modifiedTasks
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:@"edit_bits>1" forKey:@"WHERE"];
   return [self tasksWithCondition:cond];
}

- (NSArray *) pendingTasks
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"edit_bits & %d", EB_CREATED_OFFLINE] forKey:@"WHERE"];
   return [self tasksWithCondition:cond];
}

- (RTMTask *) taskForNote:(RTMNote *) note
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"id=%d", [note.task_id integerValue]] forKey:@"WHERE"];
   return [[self tasksWithCondition:cond] objectAtIndex:0];
}

- (NSNumber *) createAtOffline:(NSDictionary *)params
{
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:params];
   NSNumber *edit_bits = [NSNumber numberWithInt:EB_CREATED_OFFLINE];
   [attrs setObject:edit_bits forKey:@"edit_bits"];

   [local_cache_ insert:attrs into:@"task"];

   NSArray *iid = [NSArray arrayWithObject:@"id"];
   NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
   NSArray *ret = [local_cache_ select:iid from:@"task" option:order];
   NSNumber *retn = [[ret objectAtIndex:0] objectForKey:@"id"];
   return retn;
}

- (void) createAtOnline:(NSDictionary *)params
{
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:params];
   NSNumber *edit_bits = [NSNumber numberWithInt:0];
   [attrs setObject:edit_bits forKey:@"edit_bits"];
   [attrs setObject:[params objectForKey:@"id"] forKey:@"taskseries_id"];

   [attrs removeObjectForKey:@"id"];
   [attrs removeObjectForKey:@"created"];
   [attrs removeObjectForKey:@"modified"];
   [attrs removeObjectForKey:@"source"];

   NSArray *tasks = [attrs objectForKey:@"tasks"];
   NSArray *notes = [attrs objectForKey:@"notes"];
   NSArray *tags = [attrs objectForKey:@"tags"];

   [attrs removeObjectForKey:@"tasks"];
   [attrs removeObjectForKey:@"notes"];
   [attrs removeObjectForKey:@"tags"];

   for (NSDictionary *task in tasks) {
      NSString *deleted_str = [task objectForKey:@"deleted"];
      if (deleted_str && ! [deleted_str isEqualToString:@""])
         continue;

      NSMutableDictionary *task_attrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
      [task_attrs setObject:[task objectForKey:@"id"] forKey:@"task_id"];

      NSString *due_str = [task objectForKey:@"due"];
      if (due_str && ! [due_str isEqualToString:@""])
         [task_attrs setObject:
            [[MilponHelper sharedHelper] rtmStringToDate:
               [task objectForKey:@"due"]] forKey:@"due"];

      NSString *completed_str = [task objectForKey:@"completed"];
      if (completed_str && ! [completed_str isEqualToString:@""])
         [task_attrs setObject:
            [[MilponHelper sharedHelper] rtmStringToDate:
               [task objectForKey:@"completed"]] forKey:@"completed"];

      NSString *priority_str = [task objectForKey:@"priority"];
      NSNumber *pri = [NSNumber numberWithInt: [priority_str isEqualToString:@"N"] ?
         4 :
         [priority_str intValue]];
      [task_attrs setObject:pri forKey:@"priority"];

      [task_attrs setObject:[NSNumber numberWithInt:[[task objectForKey:@"postponed"] intValue]] forKey:@"postponed"];
      [task_attrs setObject:[task objectForKey:@"estimate"] forKey:@"estimate"];

      [local_cache_ insert:task_attrs into:@"task"];

      NSArray *iid = [NSArray arrayWithObject:@"id"];
      NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
      NSArray *ret = [local_cache_ select:iid from:@"task" option:order];
      NSNumber *retn = [[ret objectAtIndex:0] objectForKey:@"id"];

      // add notes
      for (NSDictionary *note in notes) {
         [[NoteProvider sharedNoteProvider] createNoteAtOnline:[note objectForKey:@"text"] title:[note objectForKey:@"title"] task_id:[retn integerValue] note_id:[[note objectForKey:@"id"] integerValue]];
      }

      // add tags
      for (NSString *tag in tags) {
         NSNumber *tag_id = [[TagProvider sharedTagProvider] find:tag];
         if (tag_id) {
            if (! [[TagProvider sharedTagProvider] existRelation:retn tag_id:tag_id]) 
               [[TagProvider sharedTagProvider] createRelation:retn tag_id:tag_id];
         } else {
            NSArray *tag_keys = [NSArray arrayWithObjects:@"name", @"task_id", nil];
            NSArray *tag_vals = [NSArray arrayWithObjects:tag, retn, nil];
            NSDictionary *tag_param = [NSDictionary dictionaryWithObjects:tag_vals forKeys:tag_keys];
            [[TagProvider sharedTagProvider] create:tag_param];
         }
      }
   }
}

- (void) createOrUpdate:(NSDictionary *)params
{   
   if ([self taskseriesExist:[params objectForKey:@"id"]]) {
      for (NSDictionary *task in [params objectForKey:@"tasks"]) {
         NSInteger task_id = [[task objectForKey:@"id"] integerValue];
         RTMTask *rtm_task = [self taskForTaskID:task_id];
         [[NoteProvider sharedNoteProvider] removeForTask:rtm_task];
      }
      [self removeForTaskseries:[params objectForKey:@"id"]]; // remove anyway
   }

   [self createAtOnline:params];
}

- (RTMTask *) taskForTaskID:(NSInteger) task_id
{
   NSMutableDictionary *cond = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"task_id=%d", task_id] forKey:@"WHERE"];
   return [[self tasksWithCondition:cond] objectAtIndex:0];
}

- (void) remove:(RTMTask *) task
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %d", task.iD];
   [local_cache_ delete:@"task" condition:cond];   
}
/*
- (void) removeNote:(NSNumber *) note_id
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %d", [note_id intValue]];
   [local_cache_ delete:@"note" condition:cond];
}

- (NSArray *) getNotes:(RTMTask *) task
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:
      [NSString stringWithFormat:@"task_id=%d", [task.iD intValue]]
      forKey:@"WHERE"];

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"text", nil];
   NSArray *vals = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *query = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   return [local_cache_ select:query from:@"note" option:cond];
}
*/
- (void) erase
{
   [local_cache_ delete:@"task" condition:nil];
   [local_cache_ delete:@"note" condition:nil];
   [local_cache_ delete:@"tag" condition:nil];
   [local_cache_ delete:@"task_tag" condition:nil];
   [local_cache_ delete:@"location" condition:nil];
}
/*
- (void) createNote:(NSString *)note task_id:(NSNumber *)tid
{
   NSArray *keys = [NSArray arrayWithObjects:@"text", @"task_id", @"edit_bits", nil];
   NSArray *vals = [NSArray arrayWithObjects:note, tid, [NSNumber numberWithInt:EB_CREATED_OFFLINE], nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
}
*/
- (BOOL) taskExist:(NSNumber *)task_id
{
   NSDictionary *where = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"task_id=%d", [task_id intValue]] forKey:@"WHERE"];
   NSArray *keys = [NSArray arrayWithObject:@"task_id"];
   NSArray *tasks = [local_cache_ select:keys from:@"task" option:where];
   return tasks.count == 1;
}

- (void) removeForID:(NSNumber *) task_id
{
   NSString *cond = [NSString stringWithFormat:@"WHERE task_id = %d", [task_id intValue]];
   [local_cache_ delete:@"task" condition:cond];
}

- (BOOL) taskseriesExist:(NSNumber *)taskseries_id
{
   NSDictionary *where = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"taskseries_id=%d", [taskseries_id intValue]] forKey:@"WHERE"];
   NSArray *keys = [NSArray arrayWithObject:@"taskseries_id"];
   NSArray *tasks = [local_cache_ select:keys from:@"task" option:where];
   return tasks.count > 0;
}

- (void) removeForTaskseries:(NSNumber *) taskseries_id
{
   NSString *cond = [NSString stringWithFormat:@"WHERE taskseries_id = %d", [taskseries_id intValue]];
   [local_cache_ delete:@"task" condition:cond];
}

/*
- (BOOL) noteExist:(NSNumber *)note_id
{
      NSDictionary *where = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"id=%d", [note_id intValue]] forKey:@"WHERE"];
      NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"id"];
      NSArray *tasks = [local_cache_ select:dict from:@"note" option:where];
      return tasks.count == 1;
}

- (NSArray *) todayTasks
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) tomorrowTasks
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) inAWeekTasks
{
   NSAssert(NO, @"not reach here");
   return nil;
}

*/
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
