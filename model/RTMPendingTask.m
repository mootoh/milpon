//
//  RTMPendingTask.m
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMDatabase.h"
#import "RTMPendingTask.h"
#import "MilponHelper.h"
#import "logger.h"

@implementation RTMPendingTask

- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb
{
   if (self = [super initByParams:params inDB:ddb]) {
   }
   return self;
}

+ (void) createTask:(NSDictionary *)params inDB:(RTMDatabase *)db // {{{
{
   sqlite3_stmt *stmt = nil;
   NSString *sql = @"INSERT INTO task (name, list_id, priority, edit_bits";
   
   if ([params valueForKey:@"due"]) {
      sql = [NSString stringWithFormat:@"%@, due) VALUES (?,?,?,?,?)", sql];
   } else {
      sql = [NSString stringWithFormat:@"%@) VALUES (?,?,?,?)", sql];
   }

   if (SQLITE_OK != sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL)) {
      NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   //sqlite3_bind_int(stmt,  7, [[params valueForKey:@"list_id"] intValue]);
   sqlite3_bind_int(stmt,  2, 0); // TODO
   sqlite3_bind_int(stmt,  3, [[params valueForKey:@"priority"] intValue]);
   sqlite3_bind_int(stmt,  4, EB_CREATED_OFFLINE);
   
   if ([params valueForKey:@"due"]) {
      NSString *due_date = [[MilponHelper sharedHelper] dateToString:[params valueForKey:@"due"]];
      sqlite3_bind_text(stmt, 5, [due_date UTF8String], -1, SQLITE_TRANSIENT);
   }

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_finalize(stmt);
} // }}}

+ (void) createNote:(NSString *)note withID:(NSNumber *)task_series_id inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "INSERT INTO note "
      "(text, task_series_id, edit_bits) "
      "VALUES (?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [note UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  2, [task_series_id intValue]);
   sqlite3_bind_int(stmt,  3, EB_CREATED_OFFLINE);

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_finalize(stmt);
}

+(NSNumber *) getID:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "SELECT id from task where "
      "priority=? AND edit_bits=? AND name=? AND list_id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }

   sqlite3_bind_int(stmt,  1, [[params valueForKey:@"priority"] intValue]);
   sqlite3_bind_int(stmt,  2, EB_CREATED_OFFLINE);
   sqlite3_bind_text(stmt, 3, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  4, [[params valueForKey:@"list_id"] intValue]);


   int ret = -1;
   if (SQLITE_ROW == sqlite3_step(stmt)) {
      ret = sqlite3_column_int(stmt, 0);
   } else {
      NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }

   sqlite3_finalize(stmt);

   return [NSNumber numberWithInt:ret];
}

// TODO: add tags
+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db // {{{
{
   [RTMPendingTask createTask:params inDB:db];

   NSString *note = [params valueForKey:@"note"];
   if (note && ! [note isEqualToString:@""]) {
      NSNumber *task_series_id = [RTMPendingTask getID:params inDB:db];
      if (! task_series_id) // TODO: should treat error
         return;
      [RTMPendingTask createNote:note withID:task_series_id inDB:db];
   }

} // }}}

+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where edit_bits & 1 AND (completed='' OR completed is NULL)"
      " ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC"];
   return [RTMTask tasksForSQL:sql inDB:db];
}

+ (NSArray *) getNotes:(NSNumber *)task_id fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "SELECT "
      "id, text from note "
      "WHERE task_series_id=?";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      LOG(@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }

   sqlite3_bind_int(stmt, 1, [task_id intValue]);

   NSMutableArray *ret = [[NSMutableArray alloc] init];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *note_id  = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];

      char *str = (char *)sqlite3_column_text(stmt, 1);
      NSString *text = str ? [NSString stringWithUTF8String:str] : @"";

      NSArray *keys = [NSArray arrayWithObjects:@"id", @"title", @"text", @"created", @"modified", nil];
      NSArray *values = [NSArray arrayWithObjects:note_id, @"", text, @"", @"", nil];
      NSDictionary *note = [NSDictionary dictionaryWithObjects:values forKeys:keys];
      [ret addObject:note];
   }

	[pool release];
   sqlite3_finalize(stmt);

   return ret;
}

- (NSArray *) notes
{
   return [RTMPendingTask getNotes:iD fromDB:db];
}

+ (void) removeNote:(NSNumber *)note_id fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "delete from note where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   sqlite3_bind_int(stmt, 1, [note_id intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"failed in removing %d from task.", [note_id intValue]);
      return;
   }
   sqlite3_finalize(stmt);
}

@end
// vim:set ft=objc fdm=marker:
