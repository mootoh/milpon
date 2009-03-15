//
//  RTMPendingTask.m
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "LocalCache.h"
#import "RTMPendingTask.h"
#import "MilponHelper.h"
#import "logger.h"

@implementation RTMPendingTask

- (id) initByParams:(NSDictionary *)params
{
   if (self = [super initByParams:params]) {
   }
   return self;
}

#if 0
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

+ (NSArray *) getNotes:(NSNumber *)task_id fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "SELECT "
      "id, text from note "
      "WHERE taskseries_id=?";
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
      LOG(@"failed in removing %d from task.", [note_id intValue]);
      return;
   }
   sqlite3_finalize(stmt);
}
#endif // 0
@end
// vim:set ft=objc fdm=marker:
