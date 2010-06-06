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
#import "RTMAPI.h"
#import "RTMAPI+List.h"
#import "RTMAPI+Task.h"
#import "RTMAPI+Note.h"
#import "RTMAPI+Timeline.h"
#import "ProgressView.h"
#import "MPLogger.h"
#import "ListProvider.h"
#import "TaskProvider.h"
#import "LocalCache.h"
#import "NoteProvider.h"
#import "MilponHelper.h"
#import "TagProvider.h"
#import "Reachability.h"

@implementation RTMSynchronizer
@synthesize timeLine;
@synthesize delegate;

- (id) initWithAPI:(RTMAPI *) ap
{
   if (self = [super init]) {
      api = ap;
      self.timeLine = nil;
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

   NSArray *lists = [api getList];

   NSDictionary *list;
   for (list in lists)
      [lp create:list];
}

- (void) syncLists
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   NSArray *new_lists = [api getList];
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
   [pool release];
}

- (void) replaceTasks
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   [tp erase];

   NSSet *tasks = [api getTaskList];
   if (tasks)
      [[LocalCache sharedLocalCache] updateLastSync];

   for (NSDictionary *taskseries in tasks)
      [tp createAtOnline:taskseries];

   [pool release];
}

- (void) syncTasks:(ProgressView *)progressView
{
   NSString *last_sync = [[LocalCache sharedLocalCache] lastSync];
   NSSet *taskserieses_updated = [api getTaskList:nil filter:nil lastSync:last_sync];
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

   int i=1;
   for (RTMTask *task in pendings) {
      //[progressView updateMessage:[NSString stringWithFormat:@"uploading %d/%d tasks", i, pendings.count] withProgress:(float)i/(float)pendings.count];
      progressView.message = [NSString stringWithFormat:@"uploading %d/%d tasks...", i, pendings.count];

      NSString *list_id = [task.list_id stringValue];
      NSDictionary *task_ret = [api addTask:task.name list_id:list_id timeline:timeLine];

      if (task_ret == nil)
         [[NSException
            exceptionWithName:@"RTMSynchronizerException"
            reason:[NSString stringWithFormat:@"Failed to create a task in RTM web site."]
            userInfo:nil] raise];

      // added successfuly
      NSString *taskseries_id = [task_ret objectForKey:@"id"];
      NSString *task_id       = [[[task_ret objectForKey:@"tasks"] objectAtIndex:0] objectForKey:@"id"];
      NSAssert(taskseries_id, @"");
      NSAssert(task_id, @"");

      if (task.due) {
         NSString *due = [[MilponHelper sharedHelper] dateToRtmString:task.due];
         [api setTaskDueDate:due timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id has_due_time:NO parse:NO]; // TODO: use has_due_time
      }

      if (0 != [task.location_id intValue])
         [api setTaskLocation:[task.location_id stringValue] timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];

      if (4 != [task.priority intValue]) // TODO: care priority=4s
         [api setTaskPriority:[task.priority stringValue] timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];

      if (task.estimate && ![task.estimate isEqualToString:@""]) 
         [api setTaskEstimate:task.estimate timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];

      NSArray *tags = task.tags;
      if (tags && tags.count > 0) {
         NSString *tag_str = @"";
         for (RTMTag *tg in tags)
            tag_str = [tag_str stringByAppendingFormat:@"%@,", tg.name];
         tag_str = [tag_str substringToIndex:tag_str.length-1]; // cut last ', '

         [api setTaskTags:tag_str task_id:task_id taskseries_id:taskseries_id list_id:list_id timeline:timeLine];
         for (RTMTag *tg in tags)
            [[TagProvider sharedTagProvider] remove:tg]; // TODO: update IDs instead of removing
      }

      // get Note from DB by old Task ID
      NSArray *notes = [[NoteProvider sharedNoteProvider] notesInTask:task.iD];
      for (RTMNote *note in notes) {
         // - API request (rtm.tasks.notes.add) using new Task ID
         NSDictionary *newNote = [api addNote:note.title text:note.text timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];
         if (newNote) {
            // remove old Note from DB
            [[NoteProvider sharedNoteProvider] remove:note.iD]; // TODO: update IDs instead of removing
         }
      }

      [[TaskProvider sharedTaskProvider] remove:task]; // TODO: update IDS instaed of removing

      i++;
   }
}

- (void) syncModifiedTasks:(ProgressView *)progressView
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   int i=0;
   NSArray *tasks = [[TaskProvider sharedTaskProvider] modifiedTasks];
   for (RTMTask *task in tasks) {
      if (progressView)
         //[progressView updateMessage:[NSString stringWithFormat:@"updating %d/%d, %@...", i,tasks.count, task.name] withProgress:(float)i/(float)tasks.count];
         progressView.message = [NSString stringWithFormat:@"updating %d/%d\n%@...", i,tasks.count, task.name];
      NSInteger edit_bits = task.edit_bits;

      NSString *list_id       = [task.list_id_itself stringValue];
      NSString *task_id       = [task.task_id        stringValue];
      NSString *taskseries_id = [task.taskseries_id  stringValue];
      
      if (edit_bits & EB_TASK_DUE) {
         NSString *due = [[MilponHelper sharedHelper] dateToRtmString:task.due];

         [api setTaskDueDate:due timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id has_due_time:NO parse:NO]; // TODO: use has_due_time flag
         [task flagDownEditBits:EB_TASK_DUE];
      }
      if (edit_bits & EB_TASK_COMPLETED) {
         [api completeTask:task_id taskseries_id:taskseries_id list_id:list_id timeline:timeLine];
         [task flagDownEditBits:EB_TASK_COMPLETED];
         //[[TaskProvider sharedTaskProvider] remove:task]; // TODO: do not remove, keep it in DB to review completed tasks.
         i++;
         continue;
      }
      if (edit_bits & EB_TASK_PRIORITY) {
         [api setTaskPriority:[task.priority stringValue] timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id]; // TODO: care about priority=4
         [task flagDownEditBits:EB_TASK_PRIORITY];
      }
      if (edit_bits & EB_TASK_TAG) {
         NSArray *tags = task.tags;
         NSString *tag_str = @"";
         for (RTMTag *tg in task.tags)
            tag_str = [tag_str stringByAppendingFormat:@"%@,", tg.name];
         if (tags.count > 0)
            tag_str = [tag_str substringToIndex:tag_str.length-1]; // cut last ', '
         
         [api setTaskTags:tag_str task_id:task_id taskseries_id:taskseries_id list_id:list_id timeline:timeLine];
         [task flagDownEditBits:EB_TASK_TAG];
      }

      if (edit_bits & EB_TASK_NAME) {
         [api setTaskName:task.name timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];
         [task flagDownEditBits:EB_TASK_NAME];
      }

      if (edit_bits & EB_TASK_LIST_ID) {
         [api moveTaskTo:[task.to_list_id stringValue] from_list_id:[task.list_id_itself stringValue] task_id:task_id taskseries_id:taskseries_id timeline:timeLine];
         [task flagDownEditBits:EB_TASK_LIST_ID];
      }
      i++;
   }
   
   NSArray *modified_notes = [[NoteProvider sharedNoteProvider] modifiedNotes];
   for (RTMNote *note in modified_notes) {
      RTMTask *task = [[TaskProvider sharedTaskProvider] taskForNote:note];

      NSString *list_id       = [task.list_id_itself stringValue];
      NSString *task_id       = [task.task_id        stringValue];
      NSString *taskseries_id = [task.taskseries_id  stringValue];

      if (note.edit_bits & EB_CREATED_OFFLINE) {
         NSDictionary *newNote = [api addNote:note.title text:note.text timeline:timeLine list_id:list_id taskseries_id:taskseries_id task_id:task_id];
         if (newNote)
            [[NoteProvider sharedNoteProvider] remove:note.iD]; // TODO: update IDs instead of removing
      } else if (note.edit_bits & EB_NOTE_MODIFIED) {
         [api editNote:[note.note_id stringValue] title:note.title text:note.text timeline:timeLine];
         note.edit_bits = 0;
      }
   }
   [pool release];
}

- (BOOL) is_reachable
{
#ifndef LOCAL_DEBUG
   Reachability *reach = [Reachability sharedReachability];
   reach.hostName = @"api.rememberthemilk.com";
   NetworkStatus stat =  [reach internetConnectionStatus];
   reach.networkStatusNotificationsEnabled = NO;
   if (stat == NotReachable) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Connected"
                                                   message:@"Not connected to the RTM site. Sync when you are online."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
      [av release];
      return NO;
   }
#endif // LOCAL_DEBUG
   return YES;
}

#pragma mark public interface

- (void) replaceAll
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

   self.timeLine = [api createTimeline];
   [self replaceLists];
   [self replaceTasks];
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   [delegate didReplaceAll];

   self.timeLine = nil;
}

- (void) update:(ProgressView *)progressView
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updated) name:@"updateOperationFinished" object:nil];
   [self performSelectorInBackground:@selector(updateOperation:) withObject:progressView];
}

#pragma mark helper

- (void) updateOperation:(ProgressView *)pv
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   self.timeLine = [api createTimeline];
   [self uploadPendingTasks:pv];
   [self syncModifiedTasks:pv];
   [self syncTasks:pv];

   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOperationFinished" object:nil];
   [pool release];
}

- (void) updated
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateOperationFinished" object:nil];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   [delegate didUpdate];
   self.timeLine = nil;
}

#pragma mark TODO
#if 0


- (void) refreshView
{
   UIViewController *vc = self.navigationController.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
}

#endif // 0

@end