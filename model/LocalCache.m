//
//  LocalCache.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <sqlite3.h>
#import "LocalCache.h"
#import "MPLogger.h"
#import "MilponHelper.h"

@interface LocalCache (Private)
- (NSString *) databasePath;
- (NSArray *) splitSQLs:(NSString *)migrations;
- (void) run_migration_sql:(NSString *)sql;
- (NSArray *) migrations;
@end

@implementation LocalCache

- (void) upgrade_from_1_0_to_2_0
{
   // migrate DB from 1.0 to 2.0
   [self dropTable:@"last_sync"];
   [self dropTable:@"list"];
   [self dropTable:@"location"];
   [self dropTable:@"note"];
   [self dropTable:@"tag"];
   [self dropTable:@"task"];
   
   NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"version"];   
   [self update:dict table:@"migrate_version" condition:nil];
}

-(id) init
{
   if (self = [super init]) {
      path_ = [[self databasePath] retain];
      if (SQLITE_OK != sqlite3_open([path_ UTF8String], &handle_))
         [[NSException
            exceptionWithName:@"LocalCacheException"
            reason:[NSString stringWithFormat:@"Failed to open sqlite file: path=%@, msg='%s LINE=%d'", path_, sqlite3_errmsg(handle_), __LINE__]
            userInfo:nil] raise];
   }
   return self;
}

- (void) dealloc
{
   [path_ release];
   sqlite3_close(handle_);
   [super dealloc];
}

- (NSArray *) select:(NSArray *) keys from:(NSString *)table
{
   return [self select:keys from:table option:nil];
}

- (NSArray *) select:(NSArray *) keys from:(NSString *)table option:(NSDictionary *)option
{
   sqlite3_stmt *stmt = nil;
   NSMutableArray *results = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   // construct the query.
   NSString *ks = @"";
   for (NSString *key in keys)
      ks = [ks stringByAppendingFormat:@"%@,", key];

   ks = [ks substringToIndex:ks.length-1]; // cut last ', '

   NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@", ks, table];

   NSDictionary *join = [option objectForKey:@"JOIN"];
   if (join)
      sql = [sql stringByAppendingFormat:@" JOIN %@ ON %@ ",
         [join objectForKey:@"table"], [join objectForKey:@"condition"]];

   NSString *where = [option objectForKey:@"WHERE"];
   if (where)
      sql = [sql stringByAppendingFormat:@" WHERE %@", where];

   NSString *group = [option objectForKey:@"GROUP"];
   if (group)
      sql = [sql stringByAppendingFormat:@" GROUP BY %@", group];

   NSString *order = [option objectForKey:@"ORDER"];
   if (order)
      sql = [sql stringByAppendingFormat:@" ORDER BY %@", order];

   LOG(@"SQL SELECT: %@", sql);

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK)
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to prepare statement: msg='%s, LINE=%d'", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];

   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSMutableDictionary *result = [NSMutableDictionary dictionary];
      int i = 0;

      for (NSString *key in keys) {
         id value = nil;

         switch (sqlite3_column_type(stmt, i)) {
            case SQLITE_INTEGER:
               value = [NSNumber numberWithInt:sqlite3_column_int(stmt, i)];
               break;
            case SQLITE_TEXT:
               value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
               break;
            case SQLITE_NULL:
               value = [NSNull null];
               break;
            default:
               NSAssert(NO, @"not reach here");
               abort();
         }
         NSAssert(value != nil, @"value should be set");
         [result setObject:value forKey:key];
         i++;
      }
      [results addObject:result];
   }

   [pool release];
   return results;
}

- (void) insert:(NSDictionary *)dict into:(NSString *)table
{
   sqlite3_stmt *stmt = nil;
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSString *keys = @"";
   NSString *vals = @"";

   for (NSString *key in dict) {
      keys = [keys stringByAppendingFormat:@"%@, ", key];
      id v = [dict objectForKey:key];
      NSString *val = nil;
      if ([v isKindOfClass:[NSString class]]) {
         val = [NSString stringWithFormat:@"'%@'", [(NSString *)v stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
      } else if ([v isKindOfClass:[NSNumber class]]) {
         val = [(NSNumber *)v stringValue];
      } else if ([v isKindOfClass:[NSDate class]]) {
         val = ([[[MilponHelper sharedHelper] invalidDate] isEqualToDate:v]) ?
            @"NULL" :
            [NSString stringWithFormat:@"'%@'", [[MilponHelper sharedHelper] dateToString:v]];
      } else if ([v isKindOfClass:[NSArray class]]) {
         // fall through
      } else {
         [[NSException
           exceptionWithName:@"LocalCacheException"
           reason:[NSString stringWithFormat:@"unknown typ %s for key %@, LINE=%d", object_getClassName(v), key, __LINE__]
           userInfo:nil] raise];
      }
      vals = [vals stringByAppendingFormat:@"%@, ", val];
   }

   // cut last ', '
   keys = [keys substringToIndex:keys.length-2];
   vals = [vals substringToIndex:vals.length-2];

   NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);", table, keys, vals];
   LOG(@"SQL INSERT: %@", sql);
   

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to prepare statement: msg='%s, LINE=%d'", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];
   }

   int i = 1;
   for (NSString *key in dict) {
      id v = [dict objectForKey:key];
      if ([v isKindOfClass:[NSString class]]) {
         sqlite3_bind_text(stmt, i, [(NSString *)v UTF8String], -1, SQLITE_TRANSIENT);
      } else if ([v isKindOfClass:[NSNumber class]]) {
         sqlite3_bind_int(stmt,  i, [(NSNumber *)v intValue]);
      } else if ([v isKindOfClass:[NSDate class]]) {
         v = [[MilponHelper sharedHelper] dateToString:v];
         sqlite3_bind_text(stmt, i, [(NSString *)v UTF8String], -1, SQLITE_TRANSIENT);
      } else if ([v isKindOfClass:[NSArray class]]) {
         // fall through
      } else {
         [[NSException
           exceptionWithName:@"LocalCacheException"
           reason:[NSString stringWithFormat:@"should not reach here, LINE=%d", __LINE__]
           userInfo:nil] raise];
      }
      i++;
   }

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Failed to INSERT INTO LocalCache: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
         userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
   [pool release];
}

- (void) update:(NSDictionary *)dict table:(NSString *)table condition:(NSString *)cond
{
   sqlite3_stmt *stmt = nil;
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSString *sets = @"";

   for (NSString *key in dict) {
      id v = [dict objectForKey:key];
      NSString *val = nil;
      if ([v isKindOfClass:[NSString class]]) {
         val = [NSString stringWithFormat:@"'%@'", (NSString *)v];
      } else if ([v isKindOfClass:[NSNumber class]]) {
         val = [(NSNumber *)v stringValue];
      } else if ([v isKindOfClass:[NSDate class]]) {
         val = ([[[MilponHelper sharedHelper] invalidDate] isEqualToDate:v]) ?
            @"NULL" :
            [NSString stringWithFormat:@"'%@'", [[MilponHelper sharedHelper] dateToString:v]];
      } else if ([v isKindOfClass:[NSNull class]]) {
         val = @"NULL";
      } else {
         [[NSException
           exceptionWithName:@"LocalCacheException"
           reason:[NSString stringWithFormat:@"should not reach here: key=%@, LINE=%d", key, __LINE__]
           userInfo:nil] raise];
      }
      sets = [sets stringByAppendingFormat:@"%@=%@, ", key, val];
   }

   // cut last ', '
   sets = [sets substringToIndex:sets.length-2];

   NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@", table, sets];
   sql = [sql stringByAppendingFormat:@" %@;", cond ? cond : @""];

   LOG(@"update sql = %@", sql);

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to prepare statement: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];
   }

   int i = 1;
   for (NSString *key in dict) {
      id v = [dict objectForKey:key];
      if ([v isKindOfClass:[NSString class]]) {
         sqlite3_bind_text(stmt, i, [(NSString *)v UTF8String], -1, SQLITE_TRANSIENT);
      } else if ([v isKindOfClass:[NSNumber class]]) {
         sqlite3_bind_int(stmt,  i, [(NSNumber *)v intValue]);
      } else if ([v isKindOfClass:[NSDate class]]) {
         NSString *date_str = [[MilponHelper sharedHelper] dateToString:(NSDate *)v];
         sqlite3_bind_text(stmt, i, [date_str UTF8String], -1, SQLITE_TRANSIENT);
      } else if ([v isKindOfClass:[NSNull class]]) {
         sqlite3_bind_null(stmt, i);
      } else {
         [[NSException
           exceptionWithName:@"LocalCacheException"
           reason:[NSString stringWithFormat:@"should not reach here 2, LINE=%d", __LINE__]
           userInfo:nil] raise];
      }
      i++;
   }

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Failed to UPDATE LocalCache: msg='%s, LINE=%d'", sqlite3_errmsg(handle_), __LINE__]
         userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
   [pool release];
}

- (void) delete:(NSString *)table condition:(NSString *)cond
{
   sqlite3_stmt *stmt = nil;
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@;", table, cond ? cond : @""];
   LOG(@"delete sql = %@", sql);

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to prepare statement: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];
   }

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Failed to DELETE FROM LocalCache: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
         userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
   [pool release];
}

- (NSString *) lastSync
{
   NSArray *keys = [NSArray arrayWithObject:@"sync_date"];
   NSDictionary *result = [[self select:keys from:@"last_sync"] objectAtIndex:0];
   NSString *last_sync_date = [result objectForKey:@"sync_date"];
   return last_sync_date;
}

- (void) updateLastSync
{
   NSDate *now = [NSDate date];
   NSString *last_sync = [[MilponHelper sharedHelper] dateToRtmString:now];

   NSDictionary *dict = [NSDictionary dictionaryWithObject:last_sync forKey:@"sync_date"];
   [self update:dict table:@"last_sync" condition:nil];
}

- (void) dropTable:(NSString *)table
{
   sqlite3_stmt *stmt = nil;   
   NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", table];
   LOG(@"drop table SQL = %@", sql);

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to prepare statement: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];
   }
   
   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Failed to DROP TABLE LocalCache: msg='%s', LINE=%d", sqlite3_errmsg(handle_), __LINE__]
        userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
}   

- (void) migrate
{
   for (NSString *mig_path in [self migrations]) {
      NSError *error;
      NSString *mig = [NSString stringWithContentsOfFile:mig_path encoding:NSUTF8StringEncoding error:&error];
      if (! mig) {
         [[NSException
           exceptionWithName:@"LocalCacheException"
           reason:[NSString stringWithFormat:@"failed to read migration file: %@, error=%@", mig_path, [error localizedDescription]]
           userInfo:nil] raise];
      }
      for (NSString *sql in [self splitSQLs:mig]) {
         NSString *version = [[mig_path componentsSeparatedByString:@"_"] objectAtIndex:1];
         int mig_version = [version integerValue];
         if (mig_version <= [self current_migrate_version])
            continue;
         
         [self run_migration_sql:sql];
      }
   }
}

- (NSInteger) current_migrate_version
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "select version from migrate_version";
   if (sqlite3_prepare_v2(handle_, sql, -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_)]
        userInfo:nil] raise];
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      [[NSException
        exceptionWithName:@"LocalCacheException"
        reason:[NSString stringWithFormat:@"Error: failed to exec sql with message '%s'.", sqlite3_errmsg(handle_)]
        userInfo:nil] raise];
   }
   
   NSInteger ret = sqlite3_column_int(stmt, 0);
   sqlite3_finalize(stmt);
   return ret;
}


static LocalCache *s_local_cache = nil;

+ (LocalCache *) sharedLocalCache
{
   if (s_local_cache == nil)
      s_local_cache = [[LocalCache alloc] init];
   return s_local_cache;
}

@end // LocalCache

@implementation LocalCache (Private)

- (NSString *) databasePath
{
   NSFileManager *fm = [NSFileManager defaultManager];

#ifdef UNIT_TEST

   // db path
   NSString *doc_dir = @"/tmp";
   NSString *db_path = [doc_dir stringByAppendingPathComponent:@"test.sql"];

   NSError *error;
   if ([fm fileExistsAtPath:db_path] && ! [fm removeItemAtPath:db_path error:&error]) {
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to remove existing database file with message '%@' path=%@, LINE=%d", [error localizedDescription], db_path, __LINE__]
         userInfo:nil] raise];
   }

   // from path
   NSString *from_path = [[fm currentDirectoryPath] stringByAppendingPathComponent:@"/db/test.sql"];

   if (! [fm copyItemAtPath:from_path toPath:db_path error:&error])
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to create writable database file with message '%@', from=%@, to=%@, LINE=%d", [error localizedDescription], from_path, db_path, __LINE__]
         userInfo:nil] raise];

   return db_path;

#else // UNIT_TEST

   // db path
   NSString *doc_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
   NSString *db_path = [doc_dir stringByAppendingPathComponent:@"rtm.sql"];

   NSError *error;
   if ([fm fileExistsAtPath:db_path])
      return db_path;

   // The writable database does not exist, so copy the default to the appropriate location.
   // from path
   NSString *from_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rtm.sql"];

   if (! [fm copyItemAtPath:from_path toPath:db_path error:&error])
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to create writable database file with message '%@', from=%@, to=%@.", [error localizedDescription], from_path, db_path]
         userInfo:nil] raise];

   return db_path;
#endif // UNIT_TEST
}

- (NSArray *) migrations
{
   NSMutableArray *ret = [NSMutableArray array];

   NSString *target_dir = [[NSBundle mainBundle] resourcePath];
   NSDirectoryEnumerator *dir = [[NSFileManager defaultManager] enumeratorAtPath:target_dir];
   for (NSString *mig_path in dir)
      if ([mig_path hasPrefix:@"migrate_"] && [mig_path hasSuffix:@"sql"])
         [ret addObject:[target_dir stringByAppendingPathComponent:mig_path]];

   return ret;
}

- (void) run_migration_sql:(NSString *)sql_str
{
   LOG(@"run_migration_sql: %@", sql_str);

   sqlite3_stmt *stmt = nil;
   const char *sql = [sql_str UTF8String];
   if (sqlite3_prepare_v2(handle_, sql, -1, &stmt, NULL) != SQLITE_OK) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_)]
         userInfo:nil] raise];
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Error: failed to exec sql with message '%s'.", sqlite3_errmsg(handle_)]
         userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
}

- (NSArray *) splitSQLs:(NSString *)migrations
{
   return [migrations componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
}

@end // LocalCache
