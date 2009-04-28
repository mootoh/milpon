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
   return [attrs_ objectForKey:@"task.completed"] != nil;
}

DEFINE_ATTRIBUTE(priority, Priority, NSNumber*, EB_TASK_PRIORITY);
DEFINE_ATTRIBUTE(due, Due, NSDate*, EB_TASK_DUE);


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