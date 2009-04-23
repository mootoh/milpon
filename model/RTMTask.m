#import "RTMTask.h"
#import "TaskProvider.h"
#import "logger.h"
#import "MilponHelper.h"
#import "LocalCache.h"

@implementation RTMTask

//@synthesize name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, taskseries_id, task_id, taskseries_id, has_due_time;

- (id) initByAttributes:(NSDictionary *)attrs
{
   if (self = [super init]) {
#if 0
      self.iD              = [params objectForKey:@"task.id"];
      edit_bits            = [[params objectForKey:@"task.edit_bits"] retain];

      self.task_id         = [params objectForKey:@"task.task_id"];
      if (! [[[MilponHelper sharedHelper] invalidDate] isEqualToDate:[params objectForKey:@"task.due"]])
         due               = [[params objectForKey:@"task.due"] retain];
      if (! [[[MilponHelper sharedHelper] invalidDate] isEqualToDate:[params objectForKey:@"task.completed"]])
         completed         = [[params objectForKey:@"task.completed"] retain];
      priority             = [[params objectForKey:@"task.priority"] retain];
      self.postponed       = [params objectForKey:@"task.postponed"];
      self.estimate        = [params objectForKey:@"task.estimate"];
      self.has_due_time    = [params objectForKey:@"task.has_due_time"];

      self.taskseries_id   = [params objectForKey:@"task.taskseries_id"];
      self.name            = [params objectForKey:@"task.name"];
      self.url             = [params objectForKey:@"task.url"];
      self.location_id     = [params objectForKey:@"task.location_id"];
      self.list_id         = [params objectForKey:@"task.list_id"];
      self.rrule           = [params objectForKey:@"task.rrule"];
#endif // 0
   }
   return self;
}

- (void) dealloc
{
#if 0
   [iD release];
   [edit_bits release];

   [task_id release];
   [due release];
   [completed release];
   [priority release];
   [postponed release];
   [estimate release];
   [has_due_time release];

   [taskseries_id release];
   [name release];
   [url release];
   [location_id release];
   [list_id release];
   [rrule release];

   [tags release];
   [notes release];
#endif // 0
   [super dealloc];
}
- (void) complete
{
#if 0
   self.completed = [NSDate date];
   [[TaskProvider sharedTaskProvider] complete:self];
#endif //0
}

- (void) uncomplete
{
#if 0
   [[TaskProvider sharedTaskProvider] uncomplete:self];
   self.completed = nil;
#endif // 0
}

- (BOOL) is_completed
{
#if 0
   return completed != nil;
#endif // 0
   return YES;
}

- (void) flagUpEditBits:(enum task_edit_bits_t) flag
{
#if 0
   int eb = [edit_bits intValue];
   eb |= flag;
   self.edit_bits = [NSNumber numberWithInt:eb];
#endif // 0
}

- (void) flagDownEditBits:(enum task_edit_bits_t) flag
{
#if 0
   int eb = [edit_bits intValue];
   eb = eb ^ flag;
   self.edit_bits = [NSNumber numberWithInt:eb];
#endif // 0
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

@end // RTMTask
