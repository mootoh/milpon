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

- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb 
{
   if (self = [super initByParams:params inDB:ddb]) {
      task_series_id  = [[params valueForKey:@"task_series_id"] retain];
   }
   return self;
}

- (void) dealloc
{
   [task_series_id release];
   [super dealloc];
}


+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where completed='' "
      "ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC"];
   return [RTMTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) tasksInList:(NSInteger)list_id inDB:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithFormat:@"SELECT %s from task "
      "where completed='' AND list_id=%d "
      "ORDER BY priority=0 ASC,priority ASC, due IS NULL ASC, due ASC",
      RTMTASK_SQL_COLUMNS, list_id];

   return [RTMTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) completedTasks:(RTMDatabase *)db
{
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

+ (void) createTask:(NSDictionary *)task inTaskSeries:(NSDictionary *)task_series inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "INSERT INTO task "
      "(id, due, completed, priority,   postponed, estimate, dirty, "  // task
      "task_series_id, name, url, location_id, list_id, rrule) " // TaskSeries
      "VALUES (?,?,?,?,  ?,?,?,?, ?,?,?,?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSLog(@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      @throw @"failed in createTask"; // TODO
      return;
   }

   sqlite3_bind_int(stmt,  1, [[task valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);

   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];
   sqlite3_bind_int(stmt,  4, priority);

   sqlite3_bind_int(stmt,  5, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 6, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  7, SYNCHRONIZED); 

   sqlite3_bind_int(stmt,  8, [[task_series valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 9, [[task_series valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 10, [[task_series valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt, 11, [[task_series valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt, 12, [[task_series valueForKey:@"list_id"] integerValue]);
   sqlite3_bind_text(stmt, 13, [[task_series valueForKey:@"rrule"] UTF8String], -1, SQLITE_TRANSIENT);

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSLog(@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      @throw @"failed in inserting into the database";
      return;
   }

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

+ (void) create:(NSDictionary *)task_series inDB:(RTMDatabase *)db
{
   // Tasks
   NSArray *tasks = [task_series valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      if ([[task valueForKey:@"completed"] isEqualToString:@"1"] || 
            [[task valueForKey:@"deleted"] isEqualToString:@"1"])
         continue;
      [RTMExistingTask createTask:task inTaskSeries:task_series inDB:db];
   }

   NSInteger task_series_id = [[task_series valueForKey:@"id"] integerValue];

   // Notes
   NSArray *notes = [task_series valueForKey:@"notes"];
   for (NSDictionary *note in notes)
      [RTMExistingTask createNote:note inDB:db inTaskSeries:task_series_id];

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

- (void) complete {
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
   sqlite3_bind_int(stmt, 2, [iD intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'completed' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);

   completed = @"";
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
   return [RTMExistingTask checkExisting:task_series_id forTable:@"task_series" inDB:db];
}

+ (BOOL) taskExist:(NSString *)task_id inDB:(RTMDatabase *)db {
   return [RTMExistingTask checkExisting:task_id forTable:@"task" inDB:db];
}

+ (BOOL) noteExist:(NSString *)note_id inDB:(RTMDatabase *)db {
   return [RTMExistingTask checkExisting:note_id forTable:@"note" inDB:db];
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
   if (! [RTMExistingTask taskSeriesExist:[task_series valueForKey:@"id"] inDB:db]) {
      [RTMExistingTask create:task_series inDB:db];
      return;
   }
   [RTMExistingTask updateTaskSeries:task_series inDB:db];

   // Tasks
   NSInteger task_series_id = [[task_series valueForKey:@"id"] integerValue];
   NSArray *tasks = [task_series valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      if ([RTMExistingTask taskExist:[task valueForKey:@"id"] inDB:db]) {
         [RTMExistingTask updateTask:task inDB:db inTaskSeries:task_series_id];
      } else {
         [RTMExistingTask createTask:task inTaskSeries:task_series inDB:db];
      }
   }

   // notes
   NSArray *notes = [task_series valueForKey:@"notes"];
   for (NSDictionary *note in notes) {
      if ([RTMExistingTask noteExist:[note valueForKey:@"id"] inDB:db]) {
         [RTMExistingTask updateNote:note inDB:db inTaskSeries:task_series_id];
      } else {
         [RTMExistingTask createNote:note inDB:db inTaskSeries:task_series_id];
      }
   }

   // TODO
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

   sqlite3_bind_int(stmt,  1, [task_series_id intValue]);

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

@end
