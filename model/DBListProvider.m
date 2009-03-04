//
//  DBListProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBListProvider.h"
#import "RTMList.h"
#import "LocalCache.h"
#import <sqlite3.h>

@implementation DBListProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
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
   if (sqlite3_prepare_v2([local_cache_ handle_], sql, -1, &stmt, NULL) != SQLITE_OK) {
      NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([local_cache_ handle_]));
   }
   while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSNumber *i = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
      NSString *n = [NSString stringWithUTF8String:(char *)sqlite3_column_text (stmt, 1)];
            
      RTMList *lst = [[[RTMList alloc] initWithID:i forName:n] autorelease];
      [lists addObject:lst];
   }
   sqlite3_finalize(stmt);
   [pool release];
   return lists;
}

- (NSArray *) tasksInList:(RTMList *)list
{
   return nil;
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
