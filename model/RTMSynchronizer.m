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
#import "RTMAuth.h"
#import "RTMAPIList.h"
#import "RTMAPITask.h"
#import "RTMPendingTask.h"
#import "ProgressView.h"

@implementation RTMSynchronizer

- (id) initWithDB:(RTMDatabase *)ddb withAuth:aauth {
   if (self = [super init]) {
      db_  = [ddb retain];
      auth = [aauth retain];
   }
   return self;
}

- (void) dealloc {
   [auth release];
   [db_ release];
   [super dealloc];
}

- (void) replaceLists {
   [RTMList erase:db_];

   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *lists = [api_list getList];

   NSDictionary *list;
   for (list in lists)
      [RTMList createAtOnline:list inDB:db_];
}

- (void) syncLists {
   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *new_lists = [api_list getList];
   NSArray *old_lists = [RTMList allLists:db_];

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
         [RTMList remove:old.iD fromDB:db_];
   }

   // insert only existing in news
   old_lists = [RTMList allLists:db_];
   for (new in new_lists) {
      BOOL found = NO;
      for (old in old_lists) {
         if ([old.iD stringValue] == [new objectForKey:@"id"]) {
            found = YES;
            break;
         }
      }
      if (! found)
         [RTMList createAtOnline:new inDB:db_];
   }
}

- (void) replaceTasks {
   [RTMTask erase:db_];

   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSArray *tasks = [api_task getList];
   if (tasks)
      [RTMTask updateLastSync:db_];

   for (NSDictionary *task_series in tasks)
      [RTMTask createAtOnline:task_series inDB:db_];
}

- (void) syncTasks {
   RTMAPITask *api_task = [[[RTMAPITask alloc] init] autorelease];
   NSString *last_sync = [RTMTask lastSync:db_];

   NSArray *task_serieses_updated = [api_task getListWithLastSync:last_sync];
   if (!task_serieses_updated || 0 == [task_serieses_updated count])
      return;

   [RTMTask updateLastSync:db_];

   /*
    * sync:
    *   - existing tasks
    *   - remove obsoletes
    *   - add to DB
    */
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   for (NSDictionary *task_series in task_serieses_updated)
      [RTMTask createOrUpdate:task_series inDB:db_];

   [pool release];
}

- (void) uploadPendingTasks:(ProgressView *)progressView {
   NSArray *pendings = [RTMPendingTask allTasks:db_];
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

      //[api_task setUrl:task.url forIDs:ids];
      if (task.due && ![task.due isEqualToString:@""]) 
         [api_task setDue:task.due forIDs:ids];

      if (0 != task.location_id)
         [api_task setLocation:task.location_id forIDs:ids];

      if (0 != task.priority)
         [api_task setPriority:task.priority forIDs:ids];

      if (task.estimate && ![task.estimate isEqualToString:@""]) 
         [api_task setEstimate:task.estimate forIDs:ids];

      // TODO: set tags
      // TODO: set notes

      // remove from DB
      [RTMPendingTask remove:task.iD fromDB:db_];

      [progressView updateMessage:[NSString stringWithFormat:@"uploading %d/%d tasks", i, pendings.count] withProgress:(float)i/pendings.count];
      i++;
   }

   [progressView updateMessage:@"" withProgress:1.0];
   [progressView progressEnd];
}

// TODO: sync only dirty tasks.
- (void) syncCompletedTasks {
   RTMAPITask *api_task = [[RTMAPITask alloc] init];

   NSArray *tasks = [RTMTask completedTasks:db_];
   for (NSDictionary *task in tasks) {
      if ([api_task complete:task]) {
         [RTMTask remove:[task objectForKey:@"task_id"] fromDB:db_];
      }
   }
}

@end
