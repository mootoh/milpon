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

@synthesize iD, name, url, due, location_id, priority, estimate, list_id;

- (id) initWithDB:(RTMDatabase *)ddb withParams:(NSDictionary *)params {
  if (self = [super initWithDB:ddb forID:[[params valueForKey:@"id"] integerValue]]) {
    self.name         = [params valueForKey:@"name"];
    self.url          = [params valueForKey:@"url"];
    self.due          = [params valueForKey:@"due"];
    self.location_id  = [[params valueForKey:@"location_id"] integerValue];
    self.list_id      = [[params valueForKey:@"list_id"] integerValue];
    self.priority     = [[params valueForKey:@"priority"] integerValue];
    self.estimate     = [params valueForKey:@"estimate"];
  }
  return self;
}

+ (void) createTask:(NSDictionary *)params inDB:(RTMDatabase *)db {
	sqlite3_stmt *stmt = nil;
	static const char *sql = "INSERT INTO pending_task "
    "(name, url, due, location_id, list_id, priority, estimate) "
    "VALUES (?, ?, ?, ?, ?, ?, ?)";
	if (SQLITE_OK != sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL)) {
    NSAssert1(NO, @"failed in preparing sqlite statement: '%s'.", sqlite3_errmsg([db handle]));
    return;
  }

	sqlite3_bind_text(stmt, 1, [[params valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 2, [[params valueForKey:@"url"] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 3, [[params valueForKey:@"due"] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt,  4, [[params valueForKey:@"location_id"] integerValue]);
	sqlite3_bind_int(stmt,  5, [[params valueForKey:@"list_id"] integerValue]);
	sqlite3_bind_int(stmt,  6, [[params valueForKey:@"priority"] integerValue]);
	sqlite3_bind_text(stmt, 7, [[params valueForKey:@"estimate"] UTF8String], -1, SQLITE_TRANSIENT);

	
	if (SQLITE_ERROR == sqlite3_step(stmt)) {
    NSAssert1(NO, @"failed in inserting into the database: '%s'.", sqlite3_errmsg([db handle]));
    return;
  }

	sqlite3_finalize(stmt);
}

+ (NSArray *) allTasks:(RTMDatabase *)db {
	NSMutableArray *tasks = [NSMutableArray array];
	sqlite3_stmt *stmt = nil;
  const char *sql = "SELECT id, name, url, due, location_id, list_id, priority, estimate from pending_task";

	if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
	}
	
	while (sqlite3_step(stmt) == SQLITE_ROW) {
    NSString *iD          = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];
    NSString *name        = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
    NSString *url         = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
    NSString *due         = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
    NSString *location_id = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 4)];
    NSString *list_id     = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 5)];
    NSString *priority    = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 6)];
    NSString *estimate    = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];

    NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", @"url", @"due", @"location_id", @"list_id", @"priority", @"estimate", nil];
    NSArray *vals = [NSArray arrayWithObjects:iD, name, url, due, location_id, list_id, priority, estimate, nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    RTMPendingTask *task = [[[RTMPendingTask alloc] initWithDB:db withParams:params] autorelease];
		[tasks addObject:task];
	}
	sqlite3_finalize(stmt);
	return tasks;
}

+ (void) remove:(NSInteger)iid fromDB:(RTMDatabase *)db {
	sqlite3_stmt *stmt = nil;
	static char *sql = "delete from pending_task where id=?";
	if (sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db handle]));
	}
	sqlite3_bind_int(stmt, 1, iid);

	if (sqlite3_step(stmt) == SQLITE_ERROR) {
		NSLog(@"failed in removing %d from pending_task.", iid);
		return;
	}
  sqlite3_finalize(stmt);
}

@end
