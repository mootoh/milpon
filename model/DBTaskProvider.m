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
#import "MilponHelper.h"
#import "TagProvider.h"

@implementation DBTaskProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      all_tasks_ = nil;
      dirty_all_tasks_ = YES;
   }
   return self;
}

- (void) dealloc
{
   [all_tasks_ release];
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
      RTMTask *task = [[RTMTask alloc] initByParams:dict];

      int tid = [task.iD intValue];

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
      [task release];
   }

   [pool release];
   return tasks;
}

- (NSArray *) tasks
{
   if (dirty_all_tasks_) {
      //[all_tasks_ release];
      //NSDictionary *cond = [NSDictionary dictionaryWithObject:@"deleted is NULL" forKey:@"WHERE"];
      NSDictionary *cond = [NSDictionary dictionaryWithObject:@"completed is NULL" forKey:@"WHERE"];
      all_tasks_ = [[self tasks:cond] retain];
      dirty_all_tasks_ = NO;
   }
   return all_tasks_;
}

- (NSArray *) tasksInList:(RTMList *)list
{
   NSArray *keys = [NSArray arrayWithObjects:@"WHERE", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      //[NSString stringWithFormat:@"list_id=%d AND deleted is NULL", [list.iD intValue]],
      [NSString stringWithFormat:@"list_id=%d AND completed is NULL", [list.iD intValue]],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (NSArray *) tasksInTag:(RTMTag *)tag
{
   NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
   NSArray *join_vals = [NSArray arrayWithObjects:@"task_tag", @"task.id=task_tag.task_id", nil];
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

- (NSArray *) modifiedTasks
{
   NSArray *keys = [NSArray arrayWithObjects:@"where", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"(completed='' OR completed is NULL) AND edit_bits>1"],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (NSArray *) pendingTasks
{
   NSArray *keys = [NSArray arrayWithObjects:@"where", @"ORDER", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"(completed='' OR completed is NULL) AND edit_bits & 1"],
      [NSString stringWithFormat:@"priority=0 ASC, priority ASC, due IS NULL ASC, due ASC"],
      nil];

   NSDictionary *cond = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self tasks:cond];
}

- (void) complete:(RTMTask *)task
{
   [task flagUpEditBits:EB_TASK_COMPLETED];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:task.completed forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
}

- (void) uncomplete:(RTMTask *)task
{
   [task flagUpEditBits:EB_TASK_COMPLETED];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:[[MilponHelper sharedHelper] invalidDate] forKey:@"completed"];
   [local_cache_ update:dict table:@"task" condition:[NSString stringWithFormat:@"where id=%d", [task.iD intValue]]];
}

- (NSNumber *) createAtOffline:(NSDictionary *)params
{
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:params];
   NSNumber *edit_bits = [NSNumber numberWithInt:EB_CREATED_OFFLINE];
   [attrs setObject:edit_bits forKey:@"edit_bits"];

   [local_cache_ insert:attrs into:@"task"];
   dirty_all_tasks_ = YES;

   NSDictionary *iid = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"id"];
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
   NSArray *notes = [attrs objectForKey:@"notes"]; // TODO: enable this
   NSArray *tags = [attrs objectForKey:@"tags"]; // TODO: enable this

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
         0 :
         [priority_str intValue]];
      [task_attrs setObject:pri forKey:@"priority"];

      [task_attrs setObject:[NSNumber numberWithInt:[[task objectForKey:@"postponed"] intValue]] forKey:@"postponed"];
      [task_attrs setObject:[task objectForKey:@"estimate"] forKey:@"estimate"];

      [local_cache_ insert:task_attrs into:@"task"];

      NSDictionary *iid = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"id"];
      NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
      LOG(@"task select enter");
      NSArray *ret = [local_cache_ select:iid from:@"task" option:order];
      LOG(@"task select leave");
      NSNumber *retn = [[ret objectAtIndex:0] objectForKey:@"id"];

      // add notes
      for (NSDictionary *note in notes) {
         [self createNoteAtOnline:[note objectForKey:@"text"] title:[note objectForKey:@"title"] task_id:retn];
      }

      // add tags
      for (NSString *tag in tags) {
         LOG(@"tag %@ enter", tag);
         NSNumber *tag_id = [[TagProvider sharedTagProvider] find:tag];
         if (tag_id) {
            LOG(@"tag_id %@ enter", tag);
            [[TagProvider sharedTagProvider] createRelation:retn tag_id:tag_id];
            LOG(@"tag_id %@ leaving", tag);
         } else {
            NSArray *tag_keys = [NSArray arrayWithObjects:@"name", @"task_id", nil];
            NSArray *tag_vals = [NSArray arrayWithObjects:tag, retn, nil];
            NSDictionary *tag_param = [NSDictionary dictionaryWithObjects:tag_vals forKeys:tag_keys];
            [[TagProvider sharedTagProvider] create:tag_param];
         }
         LOG(@"tag %@ leave", tag);
      }
   }
   dirty_all_tasks_ = YES;
}

- (void) remove:(RTMTask *) task
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@", [[task iD] stringValue]];
   [local_cache_ delete:@"task" condition:cond];

   dirty_all_tasks_ = YES;
}

- (void) erase
{
   [local_cache_ delete:@"task" condition:nil];
   [local_cache_ delete:@"note" condition:nil];
   [local_cache_ delete:@"tag" condition:nil];
   [local_cache_ delete:@"task_tag" condition:nil];
   [local_cache_ delete:@"location" condition:nil];

   dirty_all_tasks_ = YES;
}

- (void) createNote:(NSString *)note task_id:(NSNumber *)tid
{
   NSArray *keys = [NSArray arrayWithObjects:@"text", @"task_id", @"edit_bits", nil];
   NSArray *vals = [NSArray arrayWithObjects:note, tid, [NSNumber numberWithInt:EB_CREATED_OFFLINE], nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
}

- (void) createNoteAtOnline:(NSString *)note title:(NSString *)title task_id:(NSNumber *)tid
{
   LOG(@"createNoteAtOnline enter");
   NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"task_id", @"edit_bits", nil];
   NSMutableArray *vals = [NSMutableArray arrayWithObjects:tid, [NSNumber numberWithInt:EB_CREATED_OFFLINE], nil];

   if (title && ! [title isEqualToString:@""]) {
      [keys addObject:@"title"];
      [vals addObject:title];
   }

   if (note && ! [note isEqualToString:@""]) {
      [keys addObject:@"text"];
      [vals addObject:note];
   }

   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
   LOG(@"createNoteAtOnline leave");
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
