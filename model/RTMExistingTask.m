//
//  RTMExistingTask.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "LocalCache.h"
#import "RTMExistingTask.h"
#import "AppDelegate.h"
#import "logger.h"

@implementation RTMExistingTask

@synthesize taskseries_id;


- (id) initByParams:(NSDictionary *)params
{
   if (self = [super initByParams:params]) {
      self.taskseries_id  = [params valueForKey:@"taskseries_id"];
   }
   return self;
}

- (void) dealloc
{
   [taskseries_id release];
   [super dealloc];
}

#if 0
+ (void) createPendingTask:(NSDictionary *)task inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)taskseries_id
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO task "
      "(due, completed, priority, postponed, estimate, taskseries_id, edit_bits) "
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle_], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);
   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];

   sqlite3_bind_int(stmt,  3, priority);
   sqlite3_bind_int(stmt,  4, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 5, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, taskseries_id);
   sqlite3_bind_int(stmt,  7, 0);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createTask:(NSDictionary *)task inTaskSeries:(NSDictionary *)taskseries inDB:(RTMDatabase *)db
{
   LOG(@"RTMExistingTask.createTask: id=%@, name=%@", [task valueForKey:@"id"], [taskseries valueForKey:@"name"]);

   sqlite3_stmt *stmt = nil;
   const char *sql = "INSERT INTO task "
      "(id, due, completed, priority, postponed, estimate, "  // task
      "taskseries_id, name, url, location_id, list_id, rrule, "// TaskSeries
      "edit_bits) " 
      "VALUES (?,?,?,?,  ?,?,?,?, ?,?,?,?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSLog(@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      @throw @"failed in createTask"; // TODO
      return;
   }

   sqlite3_bind_int(stmt,   1, [[task valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt,  2, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt,  3, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);

   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];
   sqlite3_bind_int(stmt,   4, priority);

   sqlite3_bind_int(stmt,   5, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt,  6, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);

   sqlite3_bind_int(stmt,   7, [[taskseries valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt,  8, [[taskseries valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt,  9, [[taskseries valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  10, [[taskseries valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt,  11, [[taskseries valueForKey:@"list_id"] integerValue]);
   sqlite3_bind_text(stmt, 12, [[taskseries valueForKey:@"rrule"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  13, EB_SYNCHRONIZED); 

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSLog(@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      @throw @"failed in inserting into the database";
      return;
   }

   sqlite3_finalize(stmt);
}

+ (void) createNote:(NSDictionary *)note inDB:(RTMDatabase *)db inTaskSeries:(NSInteger)taskseries_id
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "INSERT INTO note "
      "(id, title, text, created, modified, taskseries_id) "
      "VALUES (?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [[note valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[note valueForKey:@"title"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[note valueForKey:@"text"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 4, [[note valueForKey:@"created"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 5, [[note valueForKey:@"modified"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, taskseries_id);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) create:(NSDictionary *)taskseries inDB:(RTMDatabase *)db
{
   // Tasks
   NSArray *tasks = [taskseries valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      if ([[task valueForKey:@"completed"] isEqualToString:@"1"] || 
            [[task valueForKey:@"deleted"] isEqualToString:@"1"])
         continue;
      [RTMExistingTask createTask:task inTaskSeries:taskseries inDB:db];
   }

   NSInteger taskseries_id = [[taskseries valueForKey:@"id"] integerValue];

   // Notes
   NSArray *notes = [taskseries valueForKey:@"notes"];
   for (NSDictionary *note in notes)
      [RTMExistingTask createNote:note inDB:db inTaskSeries:taskseries_id];

   // Tag
   NSDictionary *tags = [taskseries valueForKey:@"tags"];
   for (NSString *tag in tags) {
      // TODO: create a tag
   }
}


+ (BOOL) checkExisting:(NSString *)iD forTable:(NSString *)table inDB:(RTMDatabase *)db
{
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

+ (BOOL) taskExist:(NSString *)task_id inDB:(RTMDatabase *)db
{
   return [RTMExistingTask checkExisting:task_id forTable:@"task" inDB:db];
}

+ (BOOL) noteExist:(NSString *)note_id inDB:(RTMDatabase *)db
{
   return [RTMExistingTask checkExisting:note_id forTable:@"note" inDB:db];
}

+ (void) updateTask:(NSDictionary *)task inTaskSeries:(NSDictionary *)taskseries inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   static const char *sql = "UPDATE task SET "
      "name=?, url=?, due=?, completed=?, priority=?, postponed=?, estimate=?, rrule=?, location_id=?, list_id=?, taskseries_id=? "
      "where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   LOG(@"updateTask: name =%@", [taskseries valueForKey:@"name"]);
   sqlite3_bind_text(stmt, 1, [[taskseries valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[taskseries valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[task valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 4, [[task valueForKey:@"completed"] UTF8String], -1, SQLITE_TRANSIENT);

   NSString *pri = [task valueForKey:@"priority"];
   NSInteger priority = [pri isEqualToString:@"N"] ? 0 : [pri integerValue];
   sqlite3_bind_int(stmt,  5, priority);

   sqlite3_bind_int(stmt,  6, [[task valueForKey:@"postponed"] integerValue]);
   sqlite3_bind_text(stmt, 7, [[task valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 8, [[task valueForKey:@"rrule"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  9, [[taskseries valueForKey:@"location_id"] integerValue]);
   sqlite3_bind_int(stmt, 10, [[taskseries valueForKey:@"list_id"] integerValue]);
   sqlite3_bind_int(stmt, 11, [[taskseries valueForKey:@"id"] integerValue]);
   sqlite3_bind_int(stmt, 12, [[task valueForKey:@"id"] integerValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) updateNote:(NSDictionary *)note inDB:(RTMDatabase *)db inTaskSeries:(NSInteger) taskseries_id
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE note SET "
      "title=?, text=?, created=?, modified=?, taskseries_id=? "
      "where id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_text(stmt, 1, [[note valueForKey:@"title"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[note valueForKey:@"text"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 3, [[note valueForKey:@"created"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 4, [[note valueForKey:@"modified"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  5, taskseries_id);
   sqlite3_bind_int(stmt,  6, [[note valueForKey:@"id"] integerValue]);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in update the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) createOrUpdate:(NSDictionary *)taskseries inDB:(RTMDatabase *)db
{
   // Tasks
   NSArray *tasks = [taskseries valueForKey:@"tasks"];
   for (NSDictionary *task in tasks) {
      NSString *deleted = [task valueForKey:@"deleted"];
      if ([RTMExistingTask taskExist:[task valueForKey:@"id"] inDB:db]) {
         if (deleted && ! [deleted isEqualToString:@""]) {
            [RTMExistingTask remove:[task valueForKey:@"id"] fromDB:db];
         } else {
            [RTMExistingTask updateTask:task inTaskSeries:taskseries inDB:db];
         }
      } else {
         if (! deleted || [deleted isEqualToString:@""]) {
            [RTMExistingTask createTask:task inTaskSeries:taskseries inDB:db];
         }
      }
   }

   NSInteger taskseries_id = [[taskseries valueForKey:@"id"] integerValue];
   // notes
   NSArray *notes = [taskseries valueForKey:@"notes"];
   for (NSDictionary *note in notes) {
      if ([RTMExistingTask noteExist:[note valueForKey:@"id"] inDB:db]) {
         [RTMExistingTask updateNote:note inDB:db inTaskSeries:taskseries_id];
      } else {
         [RTMExistingTask createNote:note inDB:db inTaskSeries:taskseries_id];
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
      "WHERE taskseries_id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [taskseries_id intValue]);

   NSMutableArray *ret = [[[NSMutableArray alloc] init] autorelease];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *note_id  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];

      char *str = (char *)sqlite3_column_text(stmt, 1);
      NSString *title    = str ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 2);
      NSString *text     = str ? [NSString stringWithUTF8String:str] : @"";
      NSString *created  = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
      NSString *modified = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];

      NSArray *keys = [NSArray arrayWithObjects:@"id", @"title", @"text", @"created", @"modified", nil];
      NSArray *values = [NSArray arrayWithObjects:note_id, title, text, created, modified, nil];
      NSDictionary *note = [NSDictionary dictionaryWithObjects:values forKeys:keys];
      [ret addObject:note];
   }

	[pool release];
   sqlite3_finalize(stmt);

   return ret;
}
#endif // 0

@end
