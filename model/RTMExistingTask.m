//
//  RTMExistingTask.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMDatabase.h"
#import "RTMExistingTask.h"

@implementation RTMExistingTask

- (id) initWithDB:(RTMDatabase *)ddb withParams:(NSDictionary *)params
{
   if (self = [super initByID:[params valueForKey:@"id"] inDB:ddb]) {
      self.name            = [params valueForKey:@"name"];
      self.url             = [params valueForKey:@"url"];
      self.due             = [params valueForKey:@"due"];
      self.location        = [params valueForKey:@"location_id"];
      self.completed       = [params valueForKey:@"completed"];
      self.priority        = [params valueForKey:@"priority"];
      self.postponed       = [params valueForKey:@"postponed"];
      self.estimate        = [params valueForKey:@"estimate"];
      task_series_id       = [params valueForKey:@"task_series_id"];
   }
   return self;
}

- (void) dealloc {
   [estimate release];
   [completed release];
   [location release];
   [due release];
   [url release];
   [name release];
   [super dealloc];
}

+ (NSArray *) tasksForSQL:(NSString *)sql inDB:(RTMDatabase *)db {
   NSMutableArray *tasks = [NSMutableArray array];
   sqlite3_stmt *stmt = nil;

   if (sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   char *str;
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *task_id   = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];
      NSString *name      = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];

      str = (char *)sqlite3_column_text(stmt, 2);
      NSString *url       = (str && *str != 0) ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 3);
      NSString *due = nil;
      if (str && *str != '\0') {
         due = [NSString stringWithUTF8String:str];
         due = [due stringByReplacingOccurrencesOfString:@"T" withString:@"-"];
         due = [due stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];      
      } else {
         due = @"";
      }
      NSString *location  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 4)];
      NSString *priority  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 5)];
      NSString *postponed = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 6)];
      str = (char *)sqlite3_column_text(stmt, 7);
      NSString *estimate  = (str && *str != '\0') ? [NSString stringWithUTF8String:str] : @"";
      NSString *task_series_id  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 8)];

      NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"location_id", @"priority", @"postponed", @"estimate", @"task_series_id", nil];
      NSArray *vals = [NSArray arrayWithObjects:task_id, name, url, due, location, priority, postponed, estimate, task_series_id, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
      RTMTask *task = [[[RTMTask alloc] initWithDB:db withParams:params] autorelease];
      [tasks addObject:task];
   }
   sqlite3_finalize(stmt);
   return tasks;
}

+ (NSArray *) tasks:(RTMDatabase *)db {
   NSString *sql = [NSString stringWithUTF8String:"SELECT task.id,task_series.name,task_series.url,task.due,task_series.location_id,task.priority,task.postponed,task.estimate, task_series.id from task JOIN task_series ON task.task_series_id=task_series.id where task.completed='' ORDER BY task.due IS NULL ASC, task.due ASC, task.priority=0 ASC, task.priority ASC"];
   return [RTMExistingTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) tasksInList:(NSInteger)list_id inDB:(RTMDatabase *)db {
   NSString *sql = [NSString stringWithFormat:@"SELECT task.id,task_series.name,task_series.url,task.due,task_series.location_id,task.priority,task.postponed,task.estimate, task_series.id from task JOIN task_series ON task.task_series_id=task_series.id where task.completed='' AND list_id=%d ORDER BY task.priority=0 ASC,task.priority ASC, task.due IS NULL ASC, task.due ASC", list_id];

   //sqlite3_bind_int(stmt, 1, list_id);
   return [RTMExistingTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) completedTasks:(RTMDatabase *)db {
   NSString *sql = [NSString stringWithUTF8String:"SELECT task.id,task_series.id,task_series.list_id from task JOIN task_series ON task.task_series_id=task_series.id where task.completed='1'"];

   NSMutableArray *tasks = [NSMutableArray array];
   sqlite3_stmt *stmt = nil;

   if (sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *task_id   = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];
      NSString *task_series_id   = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 1)];
      NSString *list_id   = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 2)];

      NSArray *keys = [NSArray arrayWithObjects:@"task_id", @"task_series_id", @"list_id", nil];
      NSArray *vals = [NSArray arrayWithObjects:task_id, task_series_id, list_id, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
      [tasks addObject:params];
   }
   sqlite3_finalize(stmt);
   return tasks;
}

+ (void) createPendingTaskSeries:(NSDictionary *)task_series inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO task_series (name, url, location_id, list_id, dirty) VALUES (?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[task_series valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[task_series valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  3, [[task_series valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt,  4, [[task_series valueForKey:@"list_id"] integerValue]);
   int dirty = [task_series valueForKey:@"dirty"] ? [[task_series valueForKey:@"dirty"] intValue] : 0;
   sqlite3_bind_int(stmt,  5, dirty);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createTaskSeries:(NSDictionary *)task_series inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO task_series (id, name, url, location_id, list_id, dirty) VALUES (?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [[task_series valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[task_series valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[task_series valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  4, [[task_series valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt,  5, [[task_series valueForKey:@"list_id"] integerValue]);
   int dirty = [task_series valueForKey:@"dirty"] ? [[task_series valueForKey:@"dirty"] intValue] : 0;
   sqlite3_bind_int(stmt,  6, dirty);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createPendingTask:(NSDictionary *)task inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)task_series_id {
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO task "
      "(due, completed, priority, postponed, estimate, task_series_id, dirty) "
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);
   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];

   sqlite3_bind_int(stmt,  3, priority);
   sqlite3_bind_int(stmt,  4, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 5, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, task_series_id);
   sqlite3_bind_int(stmt,  7, 1);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createTask:(NSDictionary *)task inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)task_series_id {
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO task "
      "(id, due, completed, priority, postponed, estimate, task_series_id) "
      "VALUES (?, ?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [[task valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);
   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];

   sqlite3_bind_int(stmt,  4, priority);
   sqlite3_bind_int(stmt,  5, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 6, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  7, task_series_id);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createNote:(NSDictionary *)note inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)task_series_id {
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO note "
      "(id, title, text, created, modified, task_series_id) "
      "VALUES (?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [[note valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[note valueForKey:@"title"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[note valueForKey:@"text"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 4, [[note valueForKey:@"created"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 5, [[note valueForKey:@"modified"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, task_series_id);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createRRule:(NSDictionary *)rrule inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)task_series_id
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO rrule (every, rule, task_series_id) VALUES (?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[rrule valueForKey:@"every"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[rrule valueForKey:@"rule"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  3, task_series_id);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) create:(NSDictionary *)task_series inDB:(RTMDatabase *)db
{
   // TaskSeries
   [RTMExistingTask createTaskSeries:task_series inDB:db];

   // Tasks
   NSInteger task_series_id = [[task_series valueForKey:@"id"] integerValue];

   NSArray *tasks = [task_series valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      if ([[task valueForKey:@"completed"] isEqualToString:@"1"] || 
            [[task valueForKey:@"deleted"] isEqualToString:@"1"])
         continue;
      [RTMExistingTask createTask:task inDB:db inTaskSeries:task_series_id];
   }

   // Notes
   NSArray *notes = [task_series valueForKey:@"notes"];
   for (NSDictionary *note in notes)
      [RTMExistingTask createNote:note inDB:db inTaskSeries:task_series_id];

   // RRules
   NSDictionary *rrule = [task_series valueForKey:@"rrule"];
   if (rrule)
      [RTMExistingTask createRRule:rrule inDB:db inTaskSeries:task_series_id];

   // Tag
   NSDictionary *tags = [task_series valueForKey:@"tags"];
   for (NSString *tag in tags) {
      // TODO: create a tag
   }
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
   [RTMExistingTask erase:db from:@"task_series"];
   [RTMExistingTask erase:db from:@"task"];
   [RTMExistingTask erase:db from:@"note"];
   [RTMExistingTask erase:db from:@"tag"];
   [RTMExistingTask erase:db from:@"location"];
}

/*
 * TODO: should call finalize on error.
 */
+ (NSString *) lastSync:(RTMDatabase *)db {
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

+ (void) updateLastSync:(RTMDatabase *)db {
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

- (void) complete {
   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE task SET completed=? where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, "1", -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 2, iD);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'completed' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);
   completed = @"1";
}

- (void) uncomplete {
   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE task SET completed=? where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, "", -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 2, iD);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'completed' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);

   completed = @"";
}

- (BOOL) is_completed {
   return (completed && ![completed isEqualToString:@""]);
}

// TODO: should also remove from task_series
+ (void) remove:(NSInteger)iid fromDB:(RTMDatabase *)db {
   sqlite3_stmt *stmt = nil;
   static char *sql = "delete from task where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   sqlite3_bind_int(stmt, 1, iid);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"failed in removing %d from task.", iid);
      return;
   }
   sqlite3_finalize(stmt);
}

+ (BOOL) checkExisting:(NSString *)iD forTable:(NSString *)table inDB:(RTMDatabase *)db {
   NSString *sql = [NSString stringWithFormat:@"select count() from %@ where id=?", table];
   sqlite3_stmt *stmt = nil;
   if (sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      // TODO: use Error.
      NSLog(@"failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return YES;
   }

   sqlite3_bind_int(stmt, 1, [iD integerValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"failed in counting %d from %@.", iD), table;
      return YES;
   }

   int ret = sqlite3_column_int(stmt, 0);
   sqlite3_finalize(stmt);
   return ret > 0;
}

+ (BOOL) taskSeriesExist:(NSString *)task_series_id inDB:(RTMDatabase *)db {
   return [RTMTask checkExisting:task_series_id forTable:@"task_series" inDB:db];
}

+ (BOOL) taskExist:(NSString *)task_id inDB:(RTMDatabase *)db {
   return [RTMTask checkExisting:task_id forTable:@"task" inDB:db];
}

+ (BOOL) noteExist:(NSString *)note_id inDB:(RTMDatabase *)db {
   return [RTMTask checkExisting:note_id forTable:@"note" inDB:db];
}

+ (void) updateTaskSeries:(NSDictionary *)task_series inDB:(RTMDatabase *)db {
   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE task_series SET name=?, url=?, location_id=?, list_id=? where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[task_series valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[task_series valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  3, [[task_series valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt,  4, [[task_series valueForKey:@"list_id"] integerValue]);
   sqlite3_bind_int(stmt,  5, [[task_series valueForKey:@"id"] integerValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);

}

+ (void) updateTask:(NSDictionary *)task inDB:(RTMDatabase *)db inTaskSeries:(NSInteger) task_series_id {
   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE task SET "
      "due=?, completed=?, priority=?, postponed=?, estimate=?, task_series_id=? "
      "where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);
   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];

   sqlite3_bind_int(stmt,  3, priority);
   sqlite3_bind_int(stmt,  4, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 5, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, task_series_id);
   sqlite3_bind_int(stmt,  7, [[task valueForKey:@"id"] integerValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) updateNote:(NSDictionary *)note inDB:(RTMDatabase *)db inTaskSeries:(NSInteger) task_series_id {
   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE note "
      "title=?, text=?, created=?, modified=?, task_series_id=? "
      "where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[note valueForKey:@"title"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[note valueForKey:@"text"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[note valueForKey:@"created"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 4, [[note valueForKey:@"modified"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  5, task_series_id);
   sqlite3_bind_int(stmt,  6, [[note valueForKey:@"id"] integerValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createOrUpdate:(NSDictionary *)task_series inDB:(RTMDatabase *)db {
   // TaskSeries
   if (! [RTMTask taskSeriesExist:[task_series valueForKey:@"id"] inDB:db]) {
      [RTMTask create:task_series inDB:db];
      return;
   }
   [RTMTask updateTaskSeries:task_series inDB:db];

   // Tasks
   NSInteger task_series_id = [[task_series valueForKey:@"id"] integerValue];
   NSArray *tasks = [task_series valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      if ([RTMTask taskExist:[task valueForKey:@"id"] inDB:db]) {
         [RTMTask updateTask:task inDB:db inTaskSeries:task_series_id];
      } else {
         [RTMTask createTask:task inDB:db inTaskSeries:task_series_id];
      }
   }

   // notes
   NSArray *notes = [task_series valueForKey:@"notes"];
   for (NSDictionary *note in notes) {
      if ([RTMTask noteExist:[note valueForKey:@"id"] inDB:db]) {
         [RTMTask updateNote:note inDB:db inTaskSeries:task_series_id];
      } else {
         [RTMTask createNote:note inDB:db inTaskSeries:task_series_id];
      }
   }

   // RRules
   // TODO
#if 0
   NSDictionary *rrule = [task_series valueForKey:@"rrule"];
   if (rrule)
      if ([RTMTask rruleExist:[task valueForKey:@"id"]]) {
         [RTMTask updateNote:note inDB:db inTaskSeries:task_series_id];
      } else {
         [RTMTask createNote:note inDB:db inTaskSeries:task_series_id];
      }
}
#endif // 0
// Tag
}

- (NSArray *) notes
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "SELECT "
      "id, title, text, created, modified "
      "from note "
      "WHERE task_series_id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, task_series_id);

   NSMutableArray *ret = [[NSMutableArray alloc] init];

   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *note_id  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];
      NSString *title    = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
      NSString *text     = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
      NSString *created  = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
      NSString *modified = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];

      NSArray *keys = [NSArray arrayWithObjects:@"id", @"title", @"text", @"created", @"modified", nil];
      NSArray *values = [NSArray arrayWithObjects:note_id, title, text, created, modified, nil];
      NSDictionary *note = [NSDictionary dictionaryWithObjects:values forKeys:keys];
      [ret addObject:note];
   }

   sqlite3_finalize(stmt);

   return ret;
}

+ (void) createPendingTask:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   NSMutableDictionary *task_series = [NSMutableDictionary dictionary];

   // set attributes here for penting task.
   [task_series setObject:[params valueForKey:@"name"] forKey:@"name"];
   [task_series setObject:[params valueForKey:@"location_id"] forKey:@"location_id"];
   [task_series setObject:[params valueForKey:@"list_id"] forKey:@"list_id"];
   [task_series setObject:[NSNumber numberWithInteger:1] forKey:@"dirty"];

   NSMutableDictionary *task = [NSMutableDictionary dictionary];
   [task setObject:[params valueForKey:@"due"] forKey:@"due"];
   [task setObject:[params valueForKey:@"priority"] forKey:@"priority"];
   [task setObject:[params valueForKey:@"estimate"] forKey:@"estimate"];
   [task setObject:[NSNumber numberWithInteger:1] forKey:@"dirty"];
   NSArray *tasks = [NSArray arrayWithObject:task];
   [task_series setObject:tasks forKey:@"tasks"];

   [RTMTask create:task_series inDB:db];
}

@end
