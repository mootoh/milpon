//
//  RTMList.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMList.h"
#import "RTMTask.h"
#import "ListProvider.h"

@implementation RTMList

@synthesize iD, name;

- (id) initWithID:(NSNumber *)id_ forName:(NSString *)name_
{
   if (self = [super init]) {
      self.iD   = id_;
      self.name = name_;
   }
   return self;
}

- (void) dealloc
{
   if (iD) [iD release];
   if (name) [name release];
   [super dealloc];
}

- (NSArray *)tasks
{
   return [[ListProvider sharedListProvider] tasksInList:self];
}

#if 0
- (NSInteger) taskCount
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "SELECT count() from task where list_id=? AND (completed='' OR completed is NULL)";

   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   sqlite3_bind_int(stmt, 1, [self.iD intValue]);

   NSInteger count = (sqlite3_step(stmt) == SQLITE_ROW) ?
      sqlite3_column_int(stmt,0) : 0;
   sqlite3_finalize(stmt);
   return count;
}
#endif // 0

#if 0
+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "INSERT INTO list (id, name) VALUES(?, ?)";
   if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL))
      @throw [NSString stringWithFormat:@"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_bind_int(stmt,  1, [[params valueForKey:@"id"] integerValue]);
   sqlite3_bind_text(stmt, 2, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);

   if (SQLITE_ERROR == sqlite3_step(stmt))
      @throw [NSString stringWithFormat:@"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle])];

   sqlite3_finalize(stmt);
}

+ (void) erase:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "delete from list";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"erase all lists from DB failed.");
      return;
   }
   sqlite3_finalize(stmt);
}

+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "delete from list where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }
   sqlite3_bind_int(stmt, 1, [iid intValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"erase all lists from DB failed.");
      return;
   }
   sqlite3_finalize(stmt);
}

+ (NSString *) nameForListID:(NSNumber *) lid fromDB:(RTMDatabase *)db
{
   sqlite3_stmt *stmt = nil;
   char *sql = "SELECT name from list where id=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }

   sqlite3_bind_int(stmt, 1, [lid integerValue]);

   if (sqlite3_step(stmt) == SQLITE_ERROR)
      return nil;

   NSString *ret = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
   sqlite3_finalize(stmt);

   return ret;
}
#endif // 0
@end
