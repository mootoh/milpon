#import "RTMTask.h"
#import "TaskProvider.h"
#import "MilponHelper.h"
#import "LocalCache.h"
#import "logger.h"

@implementation RTMTask

//@synthesize name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, taskseries_id, task_id, taskseries_id, has_due_time;
/*
- (id) initByAttributes:(NSDictionary *)attrs
{
   if (self = [super initByAttributes:attrs]) {
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}
 */

- (BOOL) is_completed
{
   MilponHelper *mh = [MilponHelper sharedHelper];
   return ![[attrs_ objectForKey:@"task.completed"] isEqualToDate:[mh invalidDate]];
}

DEFINE_ATTRIBUTE(task_id, Task_id, NSNumber*, EB_TASK_TASK_ID);
DEFINE_ATTRIBUTE(priority, Priority, NSNumber*, EB_TASK_PRIORITY);
DEFINE_ATTRIBUTE(due, Due, NSDate*, EB_TASK_DUE);
DEFINE_ATTRIBUTE(completed, Completed, NSDate*, EB_TASK_COMPLETED);
DEFINE_ATTRIBUTE(list_id, List_id, NSNumber*, EB_TASK_LIST_ID);
DEFINE_ATTRIBUTE(taskseries_id, Taskseries_id, NSNumber*, EB_TASK_TASKSERIES_ID);
DEFINE_ATTRIBUTE(name, Name, NSString*, EB_TASK_NAME);
DEFINE_ATTRIBUTE(url, Url, NSString*, EB_TASK_URL);
DEFINE_ATTRIBUTE(location_id, Location_id, NSNumber*, EB_TASK_LOCACTION_ID);
DEFINE_ATTRIBUTE(estimate, Estimate, NSString*, EB_TASK_ESTIMATE);

- (void) setNote:(NSString *)note ofIndex:(NSInteger) index
{
   /* TODO: implement this
   NSArray *note_comps = [note componentsSeparatedByString:@"\n"];
   NSString *title = [note_comps objectAtIndex:0];
   NSString *body = @"";
   for (int i=1; i<note_comps.count; i++)
      body = [body stringByAppendingString:[note_comps objectAtIndex:i]];

   [self flagUpEditBits:EB_TASK_NOTE];
    */
}

+ (NSString *) table_name
{
   return @"task";
}

@end // RTMTask