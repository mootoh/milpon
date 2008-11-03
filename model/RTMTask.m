#import "RTMTask.h"
#import "RTMDatabase.h"
#import "RTMExistingTask.h"
#import "RTMPendingTask.h"

@implementation RTMTask

@synthesize name, url, due, completed, priority, postponed, estimate, rrule, tags, notes, list_id, location_id;


- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb 
{
   if (self = [super initByID:[params valueForKey:@"id"] inDB:ddb]) {
      self.name            = [params valueForKey:@"name"];
      self.url             = [params valueForKey:@"url"];
      self.due             = [params valueForKey:@"due"];
      self.location_id     = [params valueForKey:@"location_id"];
      self.completed       = [params valueForKey:@"completed"];
      self.priority        = [params valueForKey:@"priority"];
      self.postponed       = [params valueForKey:@"postponed"];
      self.estimate        = [params valueForKey:@"estimate"];
   }
   return self;
}

+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSArray * tsks = [RTMExistingTask tasks:db];
   return [tsks arrayByAddingObjectsFromArray:[RTMPendingTask tasks:db]];
}

+ (void) createAtOnline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   [RTMExistingTask create:params inDB:db];
}

+ (void) createAtOffline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
   NSMutableDictionary *task_series = [NSMutableDictionary dictionary];

   // set attributes here for penting task.
   [task_series setObject:[params valueForKey:@"name"] forKey:@"name"];
   [task_series setObject:[params valueForKey:@"location_id"] forKey:@"location_id"];
   [task_series setObject:[params valueForKey:@"list_id"] forKey:@"list_id"];

   NSMutableDictionary *task = [NSMutableDictionary dictionary];
   [task setObject:[params valueForKey:@"due"] forKey:@"due"];
   [task setObject:[params valueForKey:@"priority"] forKey:@"priority"];
   [task setObject:[params valueForKey:@"estimate"] forKey:@"estimate"];
   [task setObject:[NSNumber numberWithInteger:1] forKey:@"dirty"];
   NSArray *tasks = [NSArray arrayWithObject:task];
   [task_series setObject:tasks forKey:@"tasks"];

   [RTMPendingTask create:task_series inDB:db];
}

+ (NSArray *) tasksForSQL:(NSString *)sql inDB:(RTMDatabase *)db
{
   NSMutableArray *tasks = [NSMutableArray array];
   sqlite3_stmt *stmt = nil;

   if (sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
   }

   char *str;
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSNumber *task_id   = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
      NSString *name      = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];

      str = (char *)sqlite3_column_text(stmt, 2);
      NSString *url       = (str && *str != 0) ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 3);
      NSString *due = nil;
      if (str && *str != '\0') {
         due = [NSString stringWithUTF8String:str];
         due = [due stringByReplacingOccurrencesOfString:@"T" withString:@"-"];
         due = [due stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];      
      } else {
         due = @"";
      }
      NSString *priority  = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
      NSNumber *postponed = [NSNumber numberWithInt:sqlite3_column_int(stmt, 5)];
      str = (char *)sqlite3_column_text(stmt, 6);
      NSString *estimate  = (str && *str != '\0') ? [NSString stringWithUTF8String:str] : @"";
      str = (char *)sqlite3_column_text(stmt, 7);
      NSString *rrule     = (str && *str != '\0') ? [NSString stringWithUTF8String:str] : @"";
      NSNumber *location_id = [NSNumber numberWithInt:sqlite3_column_int(stmt, 8)];
      NSNumber *dirty     = [NSNumber numberWithInt:sqlite3_column_int(stmt, 9)];
      NSNumber *task_series_id  = [NSNumber numberWithInt:sqlite3_column_int(stmt, 10)];


      NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"priority", @"postponed", @"estimate", @"rrule", @"location_id", @"dirty", @"task_series_id", nil];
      NSArray *vals = [NSArray arrayWithObjects:task_id, name, url, due, priority, postponed, estimate, rrule, location_id, dirty, task_series_id, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

      RTMTask *task;
      if ([dirty intValue] == CREATED_OFFLINE)
         task = [[RTMPendingTask alloc] initByParams:params inDB:db];
      else
         task = [[RTMExistingTask alloc] initByParams:params inDB:db];

      [tasks addObject:task];
      [task release];
   }
   sqlite3_finalize(stmt);
   return tasks;
}




/*
 * TODO: should call finalize on error.
 */
+ (NSString *) lastSync:(RTMDatabase *)db {
   sqlite3_stmt *stmt = nil;
   const char *sql = "select * from last_sync";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return nil;
   }
   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"get 'last sync' from DB failed.");
      return nil;
   }

   char *ls = (char *)sqlite3_column_text(stmt, 0);
   if (!ls) return nil;
   NSString *result = [NSString stringWithUTF8String:ls];

   sqlite3_finalize(stmt);

   return result;
}

+ (void) updateLastSync:(RTMDatabase *)db {
   NSDate *now = [NSDate date];
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
   [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
   NSString *last_sync = [formatter stringFromDate:now];
   last_sync = [last_sync stringByReplacingOccurrencesOfString:@"_" withString:@"T"];
   last_sync = [last_sync stringByAppendingString:@"Z"];

   sqlite3_stmt *stmt = nil;
   const char *sql = "UPDATE last_sync SET sync_date=?";
   if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
      return;
   }

   sqlite3_bind_text(stmt, 1, [last_sync UTF8String], -1, SQLITE_TRANSIENT);

   if (sqlite3_step(stmt) == SQLITE_ERROR) {
      NSLog(@"update 'last sync' to DB failed.");
      return;
   }

   sqlite3_finalize(stmt);
}

@end // RTMTask
