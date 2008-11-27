#import "RTMTask.h"
#import "RTMDatabase.h"
#import "RTMExistingTask.h"
#import "RTMPendingTask.h"
#import "logger.h"

@implementation RTMTask

@synthesize name, url, completed, postponed, estimate, rrule, tags, notes, list_id, location_id, edit_bits;


- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb 
{
   if (self = [super initByID:[params valueForKey:@"id"] inDB:ddb]) {
      self.name         = [params valueForKey:@"name"];
      self.url          = [params valueForKey:@"url"];
      due               = [[params valueForKey:@"due"] retain];
      self.location_id  = [params valueForKey:@"location_id"];
      self.completed    = [params valueForKey:@"completed"];
      priority          = [[params valueForKey:@"priority"] retain];
      self.postponed    = [params valueForKey:@"postponed"];
      self.estimate     = [params valueForKey:@"estimate"];
      self.list_id      = [params valueForKey:@"list_id"];
      edit_bits         = [[params valueForKey:@"edit_bits"] retain];
   }
   return self;
}

- (BOOL) is_completed
{
   return (completed && ![completed isEqualToString:@""]);
}

- (void) complete
{
   [self flagUpEditBits:EB_TASK_COMPLETED];

   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE task SET completed=? where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, "1", -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'completed' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);
   self.completed = @"1";
}

- (void) uncomplete
{
   [self flagUpEditBits:EB_TASK_COMPLETED];

   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE task SET completed=? where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, "", -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'completed' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);
   self.completed = @"";
}


+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where completed='' OR completed is NULL"
      " ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC"];
   return [RTMTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) tasksInList:(NSNumber *)list_id inDB:(RTMDatabase *)db
{
   NSString *sql = [[NSString alloc] initWithFormat:@"SELECT %s from task "
      "where list_id=%d AND (completed='' OR completed is NULL) "
      "ORDER BY priority=0 ASC,priority ASC, due IS NULL ASC, due ASC",
      RTMTASK_SQL_COLUMNS, [list_id intValue]];

  NSArray *ret = [RTMTask tasksForSQL:sql inDB:db];
  [sql release];
  return ret;
}

+ (NSArray *) modifiedTasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where edit_bits>1"];
   return [RTMTask tasksForSQL:sql inDB:db];
}


+ (void) createAtOnline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   [RTMExistingTask create:params inDB:db];
}

+ (void) createAtOffline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   [RTMPendingTask create:params inDB:db];
}

+ (NSArray *) tasksForSQL:(NSString *)sql inDB:(RTMDatabase *)db
{
   NSMutableArray *tasks = [NSMutableArray array];
   sqlite3_stmt *stmt = nil;

   if (sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   char *str;
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSNumber *task_id   = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
      NSString *name      = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];

      str = (char *)sqlite3_column_text(stmt, 2);
      NSString *url       = (str && *str != 0) ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 3);
      NSString *due = nil;
      if (str && *str != '\0') {
         due = [NSString stringWithUTF8String:str];
         due = [due stringByReplacingOccurrencesOfString:@"T" withString:@"_"];
         due = [due stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];      
      } else {
         due = @"";
      }
      NSNumber *priority  = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
      NSNumber *postponed = [NSNumber numberWithInt:sqlite3_column_int(stmt, 5)];
      str = (char *)sqlite3_column_text(stmt, 6);
      NSString *estimate  = (str && *str != '\0') ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 7);
      NSString *rrule     = (str && *str != '\0') ? [NSString stringWithUTF8String:str] : @"";
      NSNumber *location_id = [NSNumber numberWithInt:sqlite3_column_int(stmt, 8)];
      NSNumber *list_id   = [NSNumber numberWithInt:sqlite3_column_int(stmt, 9)];
      NSNumber *task_series_id  = [NSNumber numberWithInt:sqlite3_column_int(stmt, 10)];
      NSNumber *edit_bits = [NSNumber numberWithInt:sqlite3_column_int(stmt, 11)];

      NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"priority", @"postponed", @"estimate", @"rrule", @"location_id", @"list_id", @"task_series_id",@"edit_bits", nil];
      NSArray *vals = [NSArray arrayWithObjects:task_id, name, url, due, priority, postponed, estimate, rrule, location_id, list_id, task_series_id, edit_bits, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

      RTMTask *task = ([edit_bits intValue] == EB_CREATED_OFFLINE) ?
         [[RTMPendingTask alloc] initByParams:params inDB:db] :
         [[RTMExistingTask alloc] initByParams:params inDB:db];

      [tasks addObject:task];
      [task release];
   }

   [pool release];
   sqlite3_finalize(stmt);
   return tasks;
}

+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "delete from task where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   sqlite3_bind_int(stmt, 1, [iid intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"failed in removing %d from task.", [iid intValue]);
      return;
   }
   sqlite3_finalize(stmt);
}

+ (void) erase:(RTMDatabase *)db from:(NSString *)table
{
   sqlite3_stmt *stmt = nil;
   const char *sql = [[NSString stringWithFormat:@"delete from %@", table] UTF8String];
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"erase all %@ from DB failed.", table);
      return;
   }
   sqlite3_finalize(stmt);
}

+ (void) erase:(RTMDatabase *)db
{
   [RTMExistingTask erase:db from:@"task"];
   [RTMExistingTask erase:db from:@"note"];
   [RTMExistingTask erase:db from:@"tag"];
   [RTMExistingTask erase:db from:@"location"];
}


/*
 * TODO: should call finalize on error.
 */
+ (NSString *) lastSync:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "select * from last_sync";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"get 'last sync' from DB failed.");
      return nil;
   }

   char *ls = (char *)sqlite3_column_text(stmt, 0);
   if (!ls) return nil;
   NSString *result = [NSString stringWithUTF8String:ls];

   sqlite3_finalize(stmt);

   return result;
}

+ (void) updateLastSync:(RTMDatabase *)db
{
   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
   NSString *last_sync = [formatter stringFromDate:now];
   last_sync = [last_sync stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
   last_sync = [last_sync stringByAppendingString:@"Z"];

   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE last_sync SET sync_date=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [last_sync UTF8String], -1, SQLITE_TRANSIENT);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'last sync' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);
}

- (void) dealloc
{
   if (edit_bits) [edit_bits release];
   if (name) [name release];
   if (url) [url release];
   if (due) [due release];
   if (completed) [completed release];
   if (priority) [priority release];
   if (postponed) [postponed release];
   if (estimate) [estimate release];
   if (rrule) [rrule release];
   if (tags) [tags release];
   if (notes) [notes release];
   if (list_id) [list_id release];
   if (location_id) [location_id release];

   [super dealloc];
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
   if (priority) [priority release];
   priority = [pri retain];

   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE task SET priority=? where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt, 1, [priority intValue]);
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);

   [self flagUpEditBits:EB_TASK_PRIORITY];
}

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
   [due retain];

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


@end // RTMTask
