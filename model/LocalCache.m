//
//  LocalCache.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <sqlite3.h>
#import "LocalCache.h"
#import "logger.h"

@interface LocalCache (Private)
- (NSString *) databasePath;
- (NSArray *) splitSQLs:(NSString *)migrations;
- (void) run_migration_sql:(NSString *)sql;
- (NSArray *) migrations;
- (void) migrate;
- (int) current_migrate_version;
@end

@implementation LocalCache

-(id) init
{
   if (self = [super init]) {
      path_ = [[self databasePath] retain];
      if (SQLITE_OK == sqlite3_open([path_ UTF8String], &handle_)) {
         [self migrate];
      }
   }
   return self;
}

- (void) dealloc
{
   [path_ release];
   sqlite3_close(handle_);
   [super dealloc];
}

- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table
{
   return [self select:dict from:table option:nil];
}

- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table option:(NSDictionary *)option
{
   sqlite3_stmt *stmt = nil;

   NSString *keys = @"";
   for (NSString *key in dict)
      keys = [keys stringByAppendingFormat:@"%@, ", key];

   keys = [keys substringToIndex:keys.length-2]; // cut last ', '

   NSString *sql = [NSString stringWithFormat:@"SELECT %@ from %@", keys, table];

   if (option) {
      // TODO
   }

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_));
   }

   NSMutableArray *results = [NSMutableArray array];
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSMutableDictionary *result = [NSMutableDictionary dictionary];
      int i = 0;

      for (NSString *key in dict) {
         Class klass = [dict objectForKey:key];
         if (klass == [NSNumber class]) {
            NSNumber *num = [NSNumber numberWithInt:sqlite3_column_int(stmt, i)];
            [result setObject:num forKey:key];
         } else if (klass == [NSString class]) {
            char *chs = (char *)sqlite3_column_text(stmt, i);
            NSString *str = chs ? [NSString stringWithUTF8String:chs] : @"";
            [result setObject:str forKey:key];
         } else {
            NSAssert(NO, @"not reach here!");
         }
         i++;
      }
      [results addObject:result];
   }
   return [results retain];
}

- (void) insert:(NSDictionary *)dict into:(NSString *)table
{
   sqlite3_stmt *stmt = nil;

   NSString *keys = @"";
   NSString *vals = @"";

   for (NSString *key in dict) {
      keys = [keys stringByAppendingFormat:@"%@, ", key];
      id v = [dict objectForKey:key];
      NSString *val = nil;
      if ([v isKindOfClass:[NSString class]]) {
         val = [NSString stringWithFormat:@"'%@'", (NSString *)v];
      } else if ([v isKindOfClass:[NSNumber class]]) {
         val = [(NSNumber *)v stringValue];
      } else {
         NSAssert(NO, @"not reach here");
      }
      vals = [vals stringByAppendingFormat:@"%@, ", val];
   }

   // cut last ', '
   keys = [keys substringToIndex:keys.length-2];
   vals = [vals substringToIndex:vals.length-2];

   NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);", table, keys, vals];

   if (sqlite3_prepare_v2(handle_, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_));
   }

   int i = 1;
   for (NSString *key in dict) {
      id v = [dict objectForKey:key];
      if ([v isKindOfClass:[NSString class]]) {
         sqlite3_bind_text(stmt, i, [(NSString *)v UTF8String], -1, SQLITE_TRANSIENT);
      } else if ([v isKindOfClass:[NSNumber class]]) {
         sqlite3_bind_int(stmt,  i, [(NSNumber *)v intValue]);
      } else {
         NSAssert(NO, @"not reach here");
      }
      i++;
   }

   if (SQLITE_ERROR == sqlite3_step(stmt)) {
      [[NSException
         exceptionWithName:@"LocalCacheException"
         reason:[NSString stringWithFormat:@"Failed to insert into LocalCache: msg='%s'", sqlite3_errmsg(handle_)]
         userInfo:nil] raise];
   }
   sqlite3_finalize(stmt);
}

static LocalCache *s_local_cache = nil;

+ (LocalCache *) sharedLocalCache
{
   if (s_local_cache == nil) {
      s_local_cache = [[LocalCache alloc] init];
   }
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
         reason:[NSString stringWithFormat:@"Failed to remove existing database file with message '%@' path=%@.", [error localizedDescription], db_path]
         userInfo:nil] raise];
   }

   // from path
   NSString *from_path = [[fm currentDirectoryPath] stringByAppendingPathComponent:@"/db/test.sql"];

   if (! [fm copyItemAtPath:from_path toPath:db_path error:&error])
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to create writable database file with message '%@', from=%@, to=%@.", [error localizedDescription], from_path, db_path]
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

- (void) migrate
{
   for (NSString *mig_path in [self migrations]) {
      NSError *error;
      NSString *mig = [NSString stringWithContentsOfFile:mig_path encoding:NSUTF8StringEncoding error:&error];
      if (! mig) {
         NSAssert2(0, @"failed to read migration file: %@, error=%@", mig_path, [error localizedDescription]);
         return;
      }
      for (NSString *sql in [self splitSQLs:mig]) {
         NSString *version = [[mig_path componentsSeparatedByString:@"_"] objectAtIndex:1];
         int mig_version = [version integerValue];
         if (mig_version <= [self current_migrate_version])
            continue;
         
         [self run_migration_sql:sql];
      }

      if (! [[NSFileManager defaultManager] removeItemAtPath:mig_path error:&error]) {
         NSAssert1(0, @"Failed to remove used migration: %@", mig_path);
         return;
      }
   }
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
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_));
      return;
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSAssert1(0, @"Error: failed to exec sql with message '%s'.", sqlite3_errmsg(handle_));
      return;
   }
   sqlite3_finalize(stmt);
}

- (NSArray *) splitSQLs:(NSString *)migrations
{
   return [migrations componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
}

- (int) current_migrate_version
{
   sqlite3_stmt *stmt = nil;
   const char *sql = "select version from migrate_version";
   if (sqlite3_prepare_v2(handle_, sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle_));
      return - 1;
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSAssert1(0, @"Error: failed to exec sql with message '%s'.", sqlite3_errmsg(handle_));
      return -1;
   }

   int ret = sqlite3_column_int(stmt, 0);
   sqlite3_finalize(stmt);
   return ret;
}

@end // LocalCache
