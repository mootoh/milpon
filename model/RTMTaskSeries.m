//
//  RTMTaskSeries.m
//  Milpon
//
//  Created by mootoh on 10/2/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMTaskSeries.h"
#import "RTMDatabase.h"

@implementation RTMTaskSeries
@synthesize iD, created, modified, name, source, url, location_id, list_id, participants, notes, tags, tasks;

- (id) init:(NSInteger)i created:(NSString *)c modified:(NSString *)m name:(NSString *)n source:(NSString *)s url:(NSString *)u location:(NSInteger )l list_id:(NSInteger)li
{
	if (self = [super self]) {
		self.iD = i;
		self.created = c;
		self.modified = m;
		self.name = n;
		self.source = s;
		self.url = u;
		self.location_id = l;
		self.list_id = li;
		
		// collect paritipants
		// collect notes
		// collect tags
		// collect tasks
	}
	return self;
}

- (id) initByID:(NSInteger) iid
{
  if (self = [super init]) {
    sqlite3_stmt *stmt = nil;
    static const char *sql = "SELECT * from task_series where id=?";
    if (sqlite3_prepare_v2([RTMDatabase db], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
    }
    sqlite3_bind_int(stmt, 1, iid);
    if (sqlite3_step(stmt) == SQLITE_ROW) {
      char *str;
      str = (char *)sqlite3_column_text(stmt, 1);
      self.created = str ? [NSString stringWithUTF8String:str] : @"";

      str = (char *)sqlite3_column_text(stmt, 2);
      self.modified = str ? [NSString stringWithUTF8String:str] : @"";
      
      str = (char *)sqlite3_column_text(stmt, 3);
      self.name = str ? [NSString stringWithUTF8String:str] : @"";
      
      str = (char *)sqlite3_column_text(stmt, 4);
      self.source = str ? [NSString stringWithUTF8String:str] : @"";
      
      str = (char *)sqlite3_column_text(stmt, 5);
      self.url = str ? [NSString stringWithUTF8String:str] : @"";
      
      self.location_id = sqlite3_column_int(stmt, 6);
      
      self.list_id = sqlite3_column_int(stmt, 7);
    } 
  }
  return self;
}

+ (NSArray *) collectTasks:(sqlite3_stmt *)stmt forListID:(NSInteger)list_id
{
  NSMutableArray *tasks = [NSMutableArray array];
  
  while (sqlite3_step(stmt) == SQLITE_ROW) {
    NSInteger i = sqlite3_column_int(stmt, 0);
    
    char *str;
    str = (char *)sqlite3_column_text(stmt, 1);
    NSString *c = str ? [NSString stringWithUTF8String:str] : @"";
    
    str = (char *)sqlite3_column_text(stmt, 2);
    NSString *m = str ? [NSString stringWithUTF8String:str] : @"";
    
    str = (char *)sqlite3_column_text(stmt, 3);
    NSString *n = str ? [NSString stringWithUTF8String:str] : @"";
    
    str = (char *)sqlite3_column_text(stmt, 4);
    NSString *s = str ? [NSString stringWithUTF8String:str] : @"";
    
    str = (char *)sqlite3_column_text(stmt, 5);
    NSString *u = str ? [NSString stringWithUTF8String:str] : @"";
    
    NSInteger l = sqlite3_column_int(stmt, 6);
    
    if (0 == list_id)
      list_id = sqlite3_column_int(stmt, 7);
    
    RTMTaskSeries *ts = [[[RTMTaskSeries alloc] init:i created:c modified:m name:n source:s url:u location:l list_id:list_id] autorelease];
    
    [tasks addObject:ts];
  }
  return tasks;
}

+ (NSArray *) allTaskSerieses
{
  sqlite3_stmt *stmt = nil;
  static const char *sql = "SELECT * from task_series";
  if (sqlite3_prepare_v2([RTMDatabase db], sql, -1, &stmt, NULL) != SQLITE_OK) {
    NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
  }
  return [RTMTaskSeries collectTasks:stmt forListID:0];
}

+ (NSArray *) taskSeriesesIn:(NSInteger)list_id
{	
  sqlite3_stmt *stmt = nil;
  static const char *sql = "SELECT * from task_series where list_id=?";
  if (sqlite3_prepare_v2([RTMDatabase db], sql, -1, &stmt, NULL) != SQLITE_OK) {
    NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
  }
  sqlite3_bind_int(stmt, 1, list_id);
  return [RTMTaskSeries collectTasks:stmt forListID:list_id];
}

+ (void) erase
{
	sqlite3_stmt *stmt = nil;
	static char *sql = "delete from task_series";
	if (sqlite3_prepare_v2([RTMDatabase db], sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
	}
	if (sqlite3_step(stmt) == SQLITE_ERROR) {
		NSLog(@"erase all lists from DB failed.");
		return;
	}  
}

- (void) save
{
  sqlite3_stmt *stmt = nil;
  static char *sql = "INSERT INTO task_series (id, created, modified, name, source, url, location_id, list_id) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
  if (sqlite3_prepare_v2([RTMDatabase db], sql, -1, &stmt, NULL) != SQLITE_OK) {
    NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
  }
  sqlite3_bind_int(stmt, 1, iD);
  sqlite3_bind_text(stmt, 2, [created UTF8String], -1, SQLITE_TRANSIENT);
  sqlite3_bind_text(stmt, 3, [modified UTF8String], -1, SQLITE_TRANSIENT);
  sqlite3_bind_text(stmt, 4, [name UTF8String], -1, SQLITE_TRANSIENT);
  sqlite3_bind_text(stmt, 5, [source UTF8String], -1, SQLITE_TRANSIENT);
  sqlite3_bind_text(stmt, 6, [url UTF8String], -1, SQLITE_TRANSIENT);
  sqlite3_bind_int(stmt, 7, location_id);
  sqlite3_bind_int(stmt, 8, list_id);
  
  int success = sqlite3_step(stmt);
  if (success == SQLITE_ERROR) {
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg([RTMDatabase db]));
  }
  sqlite3_finalize(stmt);
}

@end
