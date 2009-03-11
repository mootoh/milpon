#import "RTMTask.h"
#import "TaskProvider.h"
#import "logger.h"
#import "MilponHelper.h"
#import "LocalCache.h"

@implementation RTMTask

@synthesize iD, name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, edit_bits, due, taskseries_id, edit_bits, task_id, taskseries_id, has_due_time;

- (id) initByParams:(NSDictionary *)params
{
   if (self = [super init]) {
      self.iD              = [params objectForKey:@"task.id"];
      self.edit_bits       = [params objectForKey:@"task.edit_bits"];

      self.task_id         = [params objectForKey:@"task.task_id"];
      if (! [[[MilponHelper sharedHelper] invalidDate] isEqualToDate:[params objectForKey:@"task.due"]])
         self.due             = [params objectForKey:@"task.due"];
      if (! [[[MilponHelper sharedHelper] invalidDate] isEqualToDate:[params objectForKey:@"task.completed"]])
         self.completed       = [params objectForKey:@"task.completed"];
      self.priority        = [params objectForKey:@"task.priority"];
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
   [[TaskProvider sharedTaskProvider] complete:self];
   self.completed = [NSDate date];
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

#if 0


- (NSString *) due
{
   return due;
}

- (void) setDue:(NSString *)du
{
   if (due) [due release];

   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   formatter.formatterBehavior = NSDateFormatterBehavior10_4;
   formatter.dateFormat = @"yyyy-MM-dd";
   NSDate *dueDate = [formatter dateFromString:du];

   formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
   formatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
   due = [formatter stringFromDate:dueDate];
   due = [due stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
   due = [due stringByAppendingString:@"Z"];

   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE task SET due=? where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [due UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);

   // fixup formats
   due = [due stringByReplacingOccurrencesOfString:@"T" withString:@"_"];
   due = [due stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];
   [due retain];

   [self flagUpEditBits:EB_TASK_DUE];
}


- (NSNumber *) edit_bits
{
   return edit_bits;
}

- (void) setEdit_bits:(NSNumber *)eb
{
   if (edit_bits) [edit_bits release];
   edit_bits = [eb retain];

   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE task SET edit_bits=? where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt, 1, [edit_bits intValue]);
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

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
