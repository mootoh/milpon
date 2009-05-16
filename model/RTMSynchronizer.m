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
#import "RTMTag.h"
#import "RTMNote.h"
#import "RTMAuth.h"
#import "RTMAPIList.h"
#import "RTMAPITask.h"
#import "RTMAPINote.h"
#import "ProgressView.h"
#import "logger.h"
#import "ListProvider.h"
#import "TaskProvider.h"
#import "LocalCache.h"
#import "NoteProvider.h"
#import "MilponHelper.h"
#import "TagProvider.h"

@implementation RTMSynchronizer

- (id) init:(RTMAuth *)aauth
{
   if (self = [super init]) {
      auth = aauth;
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (void) replaceLists
{
   ListProvider *lp = [ListProvider sharedListProvider];
   [lp erase];

   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *lists = [api_list getList];

   NSDictionary *list;
   for (list in lists)
      [lp create:list];
}

- (void) syncLists
{
   RTMAPIList *api_list = [[[RTMAPIList alloc] init] autorelease];
   NSArray *new_lists = [api_list getList];
   NSArray *old_lists = [[ListProvider sharedListProvider] lists];

   // remove only existing in olds
   RTMList *old;
   NSDictionary *new;
   for (old in old_lists) {
      BOOL found = NO;
      for (new in new_lists) {
         if (old.iD == [[new objectForKey:@"id"] integerValue]) {
            found = YES;
            break;
         }
      }
      if (! found)
         [[ListProvider sharedListProvider] remove:old];
   }

   // insert only existing in news
   old_lists = [[ListProvider sharedListProvider] lists];
   for (new in new_lists) {
      BOOL found = NO;
      for (old in old_lists) {
         if (old.iD == [[new objectForKey:@"id"] integerValue]) {
            found = YES;
            break;
         }
      }
      if (! found)
         [[ListProvider sharedListProvider] create:new];
   }
}

- (void) replaceTasks
{
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   [tp erase];

   RTMAPITask *api_task = [[RTMAPITask alloc] init];
   NSArray *tasks = [api_task getList];
   if (tasks)
      [[LocalCache sharedLocalCache] updateLastSync];

   for (NSDictionary *taskseries in tasks)
      [tp createAtOnline:taskseries];

   [api_task release];
}

- (void) syncTasks:(ProgressView *)progressView
{
   RTMAPITask *api_task = [[RTMAPITask alloc] init];
   NSString *last_sync = [[LocalCache sharedLocalCache] lastSync];

   NSArray *taskserieses_updated = [api_task getListWithLastSync:last_sync];
   [api_task release];
   if (!taskserieses_updated || 0 == [taskserieses_updated count])
      return;

   /*
    * sync:
    *   - existing tasks
    *   - remove obsoletes
    *   - add to DB
    */
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   int i=0;
   for (NSDictionary *taskseries in taskserieses_updated) {
      if (progressView)
         //[progressView updateMessage:[NSString stringWithFormat:@"syncing task %d/%d", i, taskserieses_updated.count] withProgress:(float)i/(float)taskserieses_updated.count];
         progressView.message = [NSString stringWithFormat:@"syncing task %d/%d", i, taskserieses_updated.count];

      [[TaskProvider sharedTaskProvider] createOrUpdate:taskseries];
      i++;
   }

   [pool release];

   [[LocalCache sharedLocalCache] updateLastSync];
}

- (void) uploadPendingTasks:(ProgressView *)progressView
{
   NSArray *pendings = [[TaskProvider sharedTaskProvider] pendingTasks];
   RTMAPITask *api_task = [[RTMAPITask alloc] init];

   int i=1;
   for (RTMTask *task in pendings) {
      //[progressView updateMessage:[NSString stringWithFormat:@"uploading %d/%d tasks", i, pendings.count] withProgress:(float)i/(float)pendings.count];
      progressView.message = [NSString stringWithFormat:@"uploading %d/%d tasks...", i, pendings.count];

      NSString *list_id = [task.list_id stringValue];
      NSDictionary *task_ret = [api_task add:task.name inList:list_id];
      if (task_ret == nil)
         [[NSException
            exceptionWithName:@"RTMSynchronizerException"
            reason:[NSString stringWithFormat:@"Failed to create a task in RTM web site."]
            userInfo:nil] raise];

      // added successfuly
      NSMutableDictionary *ids = [NSMutableDictionary dictionaryWithDictionary:task_ret];
      [ids setObject:list_id forKey:@"list_id"];

      if (task.due) {
         NSString *due = [[MilponHelper sharedHelper] dateToRtmString:task.due];
         [api_task setDue:due forIDs:ids];
      }

      if (0 != [task.location_id intValue])
         [api_task setLocation:[task.location_id stringValue] forIDs:ids];

      if (4 != [task.priority intValue]) // TODO: care priority=4s
         [api_task setPriority:[task.priority stringValue] forIDs:ids];

      if (task.estimate && ![task.estimate isEqualToString:@""]) 
         [api_task setEstimate:task.estimate forIDs:ids];

      NSArray *tags = task.tags;
      if (tags && tags.count > 0) {
         NSString *tag_str = @"";
         for (RTMTag *tg in tags)
            tag_str = [tag_str stringByAppendingFormat:@"%@,", tg.name];
         tag_str = [tag_str substringToIndex:tag_str.length-1]; // cut last ', '
         
         if (-1 != [api_task setTags:tag_str forIDs:ids]) {
            for (RTMTag *tg in tags)
               [[TagProvider sharedTagProvider] remove:tg]; // TODO: update IDs instead of removing            
         }
      }

      // get Note from DB by old Task ID
      RTMAPINote *api_note = [[RTMAPINote alloc] init];
      NSArray *notes = [[NoteProvider sharedNoteProvider] notesInTask:task.iD];
      for (RTMNote *note in notes) {
         // - API request (rtm.tasks.notes.add) using new Task ID
         NSInteger note_id = [api_note add:note forIDs:ids];
         if (note_id != -1) {
            // remove old Note from DB
            [[NoteProvider sharedNoteProvider] remove:note.iD]; // TODO: update IDs instead of removing
         }
      }
      [api_note release];

      [[TaskProvider sharedTaskProvider] remove:task]; // TODO: update IDS instaed of removing

      i++;
   }

	[api_task release];
}

- (void) syncModifiedTasks:(ProgressView *)progressView
{
   RTMAPITask *api_task = [[RTMAPITask alloc] init];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   int i=0;
   NSArray *tasks = [[TaskProvider sharedTaskProvider] modifiedTasks];
   for (RTMTask *task in tasks) {
      if (progressView)
         //[progressView updateMessage:[NSString stringWithFormat:@"updating %d/%d, %@...", i,tasks.count, task.name] withProgress:(float)i/(float)tasks.count];
         progressView.message = [NSString stringWithFormat:@"updating %d/%d\n%@...", i,tasks.count, task.name];
      NSInteger edit_bits = task.edit_bits;

      if (edit_bits & EB_TASK_DUE) {
         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
            [NSString stringWithFormat:@"%d", [task.list_id_itself intValue]],
            [NSString stringWithFormat:@"%d", [task.taskseries_id intValue]],
            [NSString stringWithFormat:@"%d", [task.task_id intValue]],
            nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

         NSString *due = [[MilponHelper sharedHelper] dateToRtmString:task.due];

         if ([api_task setDue:due forIDs:ids]) {
            LOG(@"setDue succeeded");
            [task flagDownEditBits:EB_TASK_DUE];
         }
      }
      if (edit_bits & EB_TASK_COMPLETED) {
         if ([api_task complete:task]) {
            [task flagDownEditBits:EB_TASK_COMPLETED];
            //[[TaskProvider sharedTaskProvider] remove:task]; // TODO: do not remove, keep it in DB to review completed tasks.
            i++;
            continue;
         }
      }
      if (edit_bits & EB_TASK_PRIORITY) {

         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
            [NSString stringWithFormat:@"%d", [task.list_id_itself intValue]],
            [NSString stringWithFormat:@"%d", [task.taskseries_id intValue]],
            [NSString stringWithFormat:@"%d", [task.task_id intValue]],
            nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

         if ([api_task setPriority:[NSString stringWithFormat:@"%d", [task.priority intValue]] forIDs:ids]) { // TODO: care about priority=4
            LOG(@"setPriority succeeded");
            [task flagDownEditBits:EB_TASK_PRIORITY];
         }
      }
      if (edit_bits & EB_TASK_TAG) {
         NSArray *tags = task.tags;
         NSString *tag_str = @"";
         for (RTMTag *tg in task.tags)
            tag_str = [tag_str stringByAppendingFormat:@"%@,", tg.name];
         if (tags.count > 0)
            tag_str = [tag_str substringToIndex:tag_str.length-1]; // cut last ', '
         
         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d", [task.list_id_itself intValue]],
                          [NSString stringWithFormat:@"%d", [task.taskseries_id intValue]],
                          [NSString stringWithFormat:@"%d", [task.task_id intValue]],
                          nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
         
         if ([api_task setTags:tag_str forIDs:ids]) {
            [task flagDownEditBits:EB_TASK_TAG];
         }
      }

      if (edit_bits & EB_TASK_NAME) {
         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
                          [task.list_id_itself stringValue],
                          [task.taskseries_id stringValue],
                          [task.task_id stringValue],
                          nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
         
         if ([api_task setName:task.name forIDs:ids])
            [task flagDownEditBits:EB_TASK_NAME];
      }

      if (edit_bits & EB_TASK_LIST_ID) {
         NSArray *keys = [NSArray arrayWithObjects:@"from_list_id", @"to_list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
                          [task.list_id_itself stringValue],
                          [task.to_list_id stringValue],
                          [task.taskseries_id stringValue],
                          [task.task_id stringValue],
                          nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

         if ([api_task moveTo:ids]) {
            [task flagDownEditBits:EB_TASK_LIST_ID];
         }
      }
      i++;
   }
   
   RTMAPINote *api_note = [[RTMAPINote alloc] init];
   NSArray *modified_notes = [[NoteProvider sharedNoteProvider] modifiedNotes];
   for (RTMNote *note in modified_notes) {
      RTMTask *task = [[TaskProvider sharedTaskProvider] taskForNote:note];
      if (note.edit_bits & EB_CREATED_OFFLINE) {
         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
                          [task.list_id_itself stringValue],
                          [task.taskseries_id stringValue],
                          [task.task_id stringValue],
                          nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
         
         NSInteger note_id = [api_note add:note forIDs:ids];
         if (note_id != -1) {
            [[NoteProvider sharedNoteProvider] remove:note.iD]; // TODO: update IDs instead of removing
         }
      } else if (note.edit_bits & EB_NOTE_MODIFIED) {
         NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_id", nil];
         NSArray *vals = [NSArray arrayWithObjects:
                          [task.list_id_itself stringValue],
                          [task.taskseries_id stringValue],
                          [task.task_id stringValue],
                          [note.note_id stringValue],
                          nil];
         NSDictionary *ids = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
         
         if ([api_note edit:ids withTitle:note.title withText:note.text])
            note.edit_bits = 0;
      }
   }
   [api_note release];
   [pool release];
   [api_task release];
}

@end