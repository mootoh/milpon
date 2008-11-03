//
//  RTMSynchronizer.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMSynchronizer.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "RTMExistingTask.h"
#import "RTMAuth.h"
#import "RTMAPIList.h"
#import "RTMAPITask.h"
#import "RTMPendingTask.h"
#import "ProgressView.h"

@implementation RTMSynchronizer

- (id) initWithDB:(RTMDatabase *)ddb withAuth:aauth
{
   if (self = [super init]) {
      db   = [ddb retain];
      auth = [aauth retain];
   }
   return self;
}

- (void) dealloc
{
   [auth release];
   [db release];
   [super dealloc];
}

- (void) replaceLists
{
   [RTMList erase:db];

   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *lists = [api_list getList];

   NSDictionary *list;
   for (list in lists)
      [RTMList create:list inDB:db];
}

- (void) syncLists
{
   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *new_lists = [api_list getList];
   NSArray *old_lists = [RTMList allLists:db];

   // remove only existing in olds
   RTMList *old;
   NSDictionary *new;
   for (old in old_lists) {
      BOOL found = NO;
      for (new in new_lists) {
         if ([old.iD stringValue] == [new objectForKey:@"id"])  {
            found = YES;
            break;
         }
      }
      if (! found)
         [RTMList remove:old.iD fromDB:db];
   }

   // insert only existing in news
   old_lists = [RTMList allLists:db];
   for (new in new_lists) {
      BOOL found = NO;
      for (old in old_lists) {
         if ([old.iD stringValue] == [new objectForKey:@"id"]) {
            found = YES;
            break;
         }
      }
      if (! found)
         [RTMList create:new inDB:db];
   }
}

- (void) replaceTasks
{
   [RTMTask erase:db];

   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSArray *tasks = [api_task getList];
   if (tasks)
      [RTMTask updateLastSync:db];

   for (NSDictionary *task_series in tasks)
      [RTMTask createAtOnline:task_series inDB:db];
}

- (void) syncTasks
{
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSString *last_sync = [RTMTask lastSync:db];

   NSArray *task_serieses_updated = [api_task getListWithLastSync:last_sync];
   if (!task_serieses_updated || 0 == [task_serieses_updated count])
      return;

   [RTMTask updateLastSync:db];

   /*
    * sync:
    *   - existing tasks
    *   - remove obsoletes
    *   - add to DB
    */
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   for (NSDictionary *task_series in task_serieses_updated)
      [RTMExistingTask createOrUpdate:task_series inDB:db];

   [pool release];
}

- (void) uploadPendingTasks:(ProgressView *)progressView
{
   NSArray *pendings = [RTMPendingTask tasks:db];
   RTMAPITask *api_task = [[RTMAPITask alloc] init];

   [progressView progressBegin];
   [progressView updateMessage:[NSString stringWithFormat:@"uploading 0/%d tasks", pendings.count]];

   int i=0;
   for (RTMPendingTask *task in pendings) {
      NSString *list_id = [task.list_id stringValue];
      NSDictionary *task_ret = [api_task add:task.name inList:list_id];

      // if added successfuly
      NSMutableDictionary *ids = [NSMutableDictionary dictionaryWithDictionary:task_ret];
      [ids setObject:list_id forKey:@"list_id"];

      if (task.due && ![task.due isEqualToString:@""]) {
         NSString *due = [task.due stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
         due = [due stringByReplacingOccurrencesOfString:@" GMT" withString:@"Z"];
         [api_task setDue:due forIDs:ids];
      }

      if (0 != [task.location_id intValue])
         [api_task setLocation:[task.location_id stringValue] forIDs:ids];

      if (0 != [task.priority intValue])
         [api_task setPriority:[task.priority stringValue] forIDs:ids];

      if (task.estimate && ![task.estimate isEqualToString:@""]) 
         [api_task setEstimate:task.estimate forIDs:ids];

      // TODO: set tags
      // TODO: set notes

      // remove from DB
      [RTMPendingTask remove:task.iD fromDB:db];

      [progressView updateMessage:[NSString stringWithFormat:@"uploading %d/%d tasks", i, pendings.count] withProgress:(float)i/pendings.count];
      i++;
   }

   [progressView updateMessage:@"" withProgress:1.0];
   [progressView progressEnd];
}

- (void) syncCompletedTasks
{
   RTMAPITask *api_task = [[RTMAPITask alloc] init];

   NSArray *tasks = [RTMTask completedTasks:db];
   for (RTMExistingTask *task in tasks) {
      if ([api_task complete:task]) {
         [RTMTask remove:task.iD fromDB:db]; // TODO: do not remove, keep it in DB to review completed tasks.
      }
   }
   [api_task release];
}

@end
