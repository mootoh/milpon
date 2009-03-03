//
//  DBListProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBListProvider.h"
#import "RTMList.h"
#import "Database.h"
#import <sqlite3.h>

@implementation DBListProvider

- (id) init
{
   if (self = [super init]) {
      db_ = [Database sharedDatabase];
      lists_ = [self lists];
   }
   return self;
}

- (void) dealloc
{
   [lists_ release];
   [super dealloc];
}

- (NSArray *) lists
{
   NSMutableArray *lists = [NSMutableArray array];
   
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   
   sqlite3_stmt *stmt = nil;
   char *sql = "SELECT id,name from list";
   if (sqlite3_prepare_v2([db_ handle], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([db_ handle]));
   }
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSString *i = [NSString stringWithFormat:@"%d", sqlite3_column_int(stmt, 0)];
      NSString *n = [NSString stringWithUTF8String:(char *)sqlite3_column_text (stmt, 1)];
      
      NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", nil];
      NSArray *vals = [NSArray arrayWithObjects:i, n, nil];
      NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
      
      RTMList *lst = [[[RTMList alloc] initByParams:params] autorelease];
      [lists addObject:lst];
   }
   sqlite3_finalize(stmt);
   [pool release];
   return lists;
}

@end

@implementation ListProvider (DB)

static DBListProvider *s_db_list_provider = nil;

+ (ListProvider *) sharedListProvider
{
   if (nil == s_db_list_provider) {
      s_db_list_provider = [[DBListProvider alloc] init];
   }
   return s_db_list_provider; 
}

@end // ListProvider (Mock)
