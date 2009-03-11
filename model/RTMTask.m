#import "RTMTask.h"
#import "TaskProvider.h"
#import "logger.h"
#import "MilponHelper.h"
#import "LocalCache.h"

@implementation RTMTask

@synthesize iD, name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, taskseries_id, task_id, taskseries_id, has_due_time;

//
// note: I use [object retain] instead of property assignment,
//       because I implemented custom assignment function to store value into DB.
//       initByParams should be called from DB.
//
- (id) initByParams:(NSDictionary *)params
{
   if (self = [super init]) {
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
   }
   return self;
}

- (void) dealloc
{
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

   [super dealloc];
}
- (void) complete
{
   self.completed = [NSDate date];
   [[TaskProvider sharedTaskProvider] complete:self];
}

- (void) uncomplete
{
   [[TaskProvider sharedTaskProvider] uncomplete:self];
   self.completed = nil;
}

- (BOOL) is_completed
{
   return completed != nil;
}

- (void) flagUpEditBits:(enum task_edit_bits_t) flag
{
   int eb = [edit_bits intValue];
   eb |= flag;
   self.edit_bits = [NSNumber numberWithInt:eb];
}

- (void) flagDownEditBits:(enum task_edit_bits_t) flag
{
   int eb = [edit_bits intValue];
   eb = eb ^ flag;
   self.edit_bits = [NSNumber numberWithInt:eb];
}

- (NSNumber *) priority
{
   return priority;
}

- (void) setPriority:(NSNumber *)pri
{
   [priority release];
   priority = [pri retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:pri forKey:@"priority"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];

   [self flagUpEditBits:EB_TASK_PRIORITY];
}

- (NSDate *) due
{
   return due;
}

- (void) setDue:(NSDate *)du
{
   [due release];
   due = [du retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:du forKey:@"due"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];

   [self flagUpEditBits:EB_TASK_DUE];
}

- (NSNumber *) edit_bits
{
   return edit_bits;
}

- (void) setEdit_bits:(NSNumber *)eb
{
   [edit_bits release];
   edit_bits = [eb retain];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:eb forKey:@"edit_bits"];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", [iD intValue]];
   [[LocalCache sharedLocalCache] update:dict table:@"task" condition:where];
}

#if 0
+ (NSArray *) modifiedTasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where edit_bits>1"];
   return [RTMTask tasksForSQL:sql inDB:db];
}
#endif // 0

- (void) dump
{
   NSLog(@"RTMTask attrs:(id, name, url, due, completed, priority, postponed, estimate, rrule, tags, notes, list_id, location_id, edit_bits) = (%d, %@, %@, %@, %@, %d, %d, %@, %@, %p, %p, %d, %d, %d)",
      [self.iD intValue],
      self.name, self.url, self.due, self.completed, 
      [self.priority intValue],
      [self.postponed intValue],
      self.estimate, self.rrule,
      self.tags, self.notes,
      [self.list_id intValue],
      [self.location_id intValue],
      [self.edit_bits intValue]);
}

@end // RTMTask
