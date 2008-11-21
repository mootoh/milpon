//
//  RTMDatabase.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMDatabase.h"
#import "logger.h"

@interface RTMDatabase (Private)
- (NSString *) databasePath;
- (NSArray *) splitSQLs:(NSString *)migrations;
- (void) run_migration_sql:(NSString *)sql;
- (NSArray *) migrations;
- (void) migrate;
@end


@implementation RTMDatabase

@synthesize handle, path;

-(id) init
{
   if (self = [super init]) {
      path = [[self databasePath] retain];
      if (SQLITE_OK == sqlite3_open([path UTF8String], &handle)) {
         [self migrate];
      }
   }
   return self;
}

- (void) dealloc
{
   [path release];
   sqlite3_close(handle);
   [super dealloc];
}

- (NSString *) databasePath
{
   NSFileManager *fileManager = [NSFileManager defaultManager];
#ifdef UNIT_TEST
   NSString *documentsDirectory = @"/tmp";
#else // UNIT_TEST
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *documentsDirectory = [paths objectAtIndex:0];
#endif // UNIT_TEST
   NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"rtm.sql"];

   NSError *error;
   if ([fileManager fileExistsAtPath:writableDBPath]) {
#ifdef UNIT_TEST
      if (! [fileManager removeItemAtPath:writableDBPath error:&error])
         NSAssert2(0, @"Failed to remove existing database file with message '%@' path=%@.", [error localizedDescription], writableDBPath);
      NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rtm.sql"];
      if (! [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error]) {
         NSAssert3(0, @"Failed to create writable database file with message '%@', from=%@, to=%@.", [error localizedDescription], defaultDBPath, writableDBPath);
      }
#endif // UNIT_TEST
   } else {
      // The writable database does not exist, so copy the default to the appropriate location.
      NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rtm.sql"];
      if (! [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error]) {
         NSAssert3(0, @"Failed to create writable database file with message '%@', from=%@, to=%@.", [error localizedDescription], defaultDBPath, writableDBPath);
      }
   }
   return writableDBPath;
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
   if (sqlite3_prepare_v2(handle, sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(handle));
      return;
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSAssert1(0, @"Error: failed to exec sql with message '%s'.", sqlite3_errmsg(handle));
      return;
   }
   sqlite3_finalize(stmt);
}

- (NSArray *) splitSQLs:(NSString *)migrations
{
   return [migrations componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
}

@end
