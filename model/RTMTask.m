#import "RTMTask.h"
#import "TaskProvider.h"
#import "MilponHelper.h"
#import "LocalCache.h"
#import "logger.h"

@implementation RTMTask

@synthesize task_id, taskseries_id, list_id, url;

- (BOOL) is_completed
{
   MilponHelper *mh = [MilponHelper sharedHelper];
   return ![[attrs_ objectForKey:@"task.completed"] isEqualToDate:[mh invalidDate]];
}

DEFINE_ATTRIBUTE_RO(task_id, NSNumber*);
DEFINE_ATTRIBUTE_RO(taskseries_id, NSNumber*);
DEFINE_ATTRIBUTE_RO(list_id, NSNumber*);
DEFINE_ATTRIBUTE_RO(url, NSString*);
DEFINE_ATTRIBUTE(priority, Priority, NSNumber*, EB_TASK_PRIORITY);
DEFINE_ATTRIBUTE(due, Due, NSDate*, EB_TASK_DUE);
DEFINE_ATTRIBUTE(completed, Completed, NSDate*, EB_TASK_COMPLETED);
DEFINE_ATTRIBUTE(name, Name, NSString*, EB_TASK_NAME);
DEFINE_ATTRIBUTE(location_id, Location_id, NSNumber*, EB_TASK_LOCACTION_ID);
DEFINE_ATTRIBUTE(estimate, Estimate, NSString*, EB_TASK_ESTIMATE);
DEFINE_ATTRIBUTE(postponed, Postponed, NSNumber*, EB_TASK_POSTPONED);
DEFINE_ATTRIBUTE(rrule, Rrule, NSString*, EB_TASK_RRULE);

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

- (NSArray *) tags
{
   return nil;
}

- (NSArray *) notes
{
   return nil;
}

- (void) complete
{
   self.completed = [NSDate date];
}

- (void) uncomplete
{
   self.completed = nil;
}

+ (NSString *) table_name
{
   return @"task";
}

@end // RTMTask