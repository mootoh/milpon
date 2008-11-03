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

+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "INSERT INTO pending_task "
      "(name, due, location_id, list_id, priority, estimate) "
      "VALUES (?, ?, ?, ?, ?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
      NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_text(stmt, 2, [[params valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
   sqlite3_bind_int(stmt,  3, [[params valueForKey:@"location_id"] intValue]);
   sqlite3_bind_int(stmt,  4, [[params valueForKey:@"list_id"] intValue]);
   sqlite3_bind_int(stmt,  5, [[params valueForKey:@"priority"] intValue]);
   sqlite3_bind_text(stmt, 6, [[params valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);


   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_finalize(stmt);
}

+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSMutableArray *tasks = [NSMutableArray array];
   sqlite3_stmt *stmt = nil;

   const char *sql = "SELECT id,name,url,due,location_id,priority,postponed,estimate, task_series_id from task where dirty=1 ORDER BY due IS NULL ASC, due ASC, priority=0 ASC, priority ASC";

   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   const NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"due", @"location_id", @"list_id", @"priority", @"estimate", nil];

   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSNumber *iD          = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
      NSString *name        = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
      NSString *due         = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
      NSNumber *location_id = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
      NSNumber *list_id     = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
      NSNumber *priority    = [NSNumber numberWithInt:sqlite3_column_int(stmt, 5)];
      NSString *estimate    = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];

      NSArray *vals = [NSArray arrayWithObjects:iD, name, due, location_id, list_id, priority, estimate, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
      RTMPendingTask *task = [[RTMPendingTask alloc] initByParams:params inDB:db];
      [tasks addObject:task];
      [task release];
   }
   sqlite3_finalize(stmt);

   [pool release];
   return tasks;
}

+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db {
   sqlite3_stmt *stmt = nil;
   char *sql = "delete from pending_task where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   sqlite3_bind_int(stmt, 1, [iid intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"failed in removing %d from pending_task.", iid);
      return;
   }
   sqlite3_finalize(stmt);
}

@end
