#import "RTMTask.h"
#import "TaskProvider.h"
#import "MilponHelper.h"
#import "LocalCache.h"
#import "logger.h"

@implementation RTMTask

//@synthesize name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, taskseries_id, task_id, taskseries_id, has_due_time;

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


- (BOOL) is_completed
{
   return [attrs_ objectForKey:@"task.completed"] != nil;
}

- (NSNumber *) priority
{
#if 0
   return priority;
#endif // 0
   return [NSNumber numberWithInt:1];
}

- (void) setPriority:(NSNumber *)pri
{
#if 0
   [priority release];
   priority = [pri retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:pri forKey:@"priority"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];

   [self flagUpEditBits:EB_TASK_PRIORITY];
#endif // 0
}

- (NSDate *) due
{
#if 0
   return due;
#endif // 0
   return [NSDate date];
}

- (void) setDue:(NSDate *)du
{
#if 0
   [due release];
   due = [du retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:du forKey:@"due"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];

   [self flagUpEditBits:EB_TASK_DUE];
#endif // 0
}

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

- (NSNumber *) edit_bits
{
#if 0
   return edit_bits;
#endif // 0
   return [NSNumber numberWithInt:1];
}

- (void) setEdit_bits:(NSNumber *)eb
{
#if 0
   [edit_bits release];
   edit_bits = [eb retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:eb forKey:@"edit_bits"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];
#endif // 0
}

+ (NSString *) table_name
{
   return @"task";
}

@end // RTMTask