//
//  RTMPendingTask.m
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMDatabase.h"
#import "RTMPendingTask.h"

@implementation RTMPendingTask

- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb
{
   if (self = [super initByParams:params inDB:ddb]) {
   }
   return self;
}

// TODO: add tags, notes
+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db // {{{
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "INSERT INTO task "
      "(due, priority, estimate, edit_bits, "  // task
      "name, location_id, list_id, rrule) "    // TaskSeries
      "VALUES (?,?,?,?,  ?,?,?,?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [[params valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  2, [[params valueForKey:@"priority"] intValue]);
   sqlite3_bind_text(stmt, 3, [[params valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  4, EB_CREATED_OFFLINE);
   sqlite3_bind_text(stmt, 5, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  6, [[params valueForKey:@"location_id"] intValue]);
   sqlite3_bind_int(stmt,  7, [[params valueForKey:@"list_id"] intValue]);
   sqlite3_bind_text(stmt, 8, [[params valueForKey:@"rrule"] UTF8String], -1, SQLITE_TRANSIENT);

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_finalize(stmt);
} // }}}

+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSString *sql = [NSString stringWithUTF8String:"SELECT " RTMTASK_SQL_COLUMNS 
      " from task where edit_bits & 1 AND (completed='' OR completed is NULL)"
      " ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC"];
   return [RTMTask tasksForSQL:sql inDB:db];
}

@end
// vim:set ft=objc fdm=marker:
