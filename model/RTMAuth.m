//
//  RTMAuth.m
//  Milpon
//
//  Created by mootoh on 9/5/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAuth.h"
#import "RTMDatabase.h"

@implementation RTMAuth

- (id) initWithDB:(RTMDatabase *)database {
  if (self = [super init]) {
    db = [database retain];

    const char *sql = "SELECT api_key,secret,frob,token,name FROM auth";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2([db handle], sql, -1, &stmt, NULL);
    if (SQLITE_OK == result) {
      while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableArray *vals = [NSMutableArray array];
        for (int i=0; i<5; i++) {
          char *val = (char *)sqlite3_column_text(stmt, i);
          NSString *str = val ? [NSString stringWithUTF8String:val] : @"";
          [vals addObject:str];
        }
        
        self.api_key       = [[vals objectAtIndex:0] retain];
        self.shared_secret = [[vals objectAtIndex:1] retain];
        self.frob          = [[vals objectAtIndex:2] retain];
        self.token         = [[vals objectAtIndex:3] retain];
        self.name          = [[vals objectAtIndex:4] retain];
        break;
      }
    } else {
      @throw [NSString stringWithFormat:@"failed in accessing database while acquring authentication. %d", result];
    }
    sqlite3_finalize(stmt);
  }
  return self;
}

- (void) dealloc {
  [db release];
  [super dealloc];
}

- (void) updateDB:(NSString *)key val:(NSString *)val {
  NSString *sql = [NSString stringWithFormat:@"UPDATE auth SET %@=?", key];
  sqlite3_stmt *stmt;
  if (SQLITE_OK == sqlite3_prepare_v2([db handle], [sql UTF8String], -1, &stmt, NULL)) {
    sqlite3_bind_text(stmt, 1, [val UTF8String], -1, SQLITE_TRANSIENT);
    if (SQLITE_ERROR == sqlite3_step(stmt)) {
			NSLog(@"update api_key failed");
			//@throw @"update api_key failed";
    }
  }
  sqlite3_finalize(stmt);
}

/* -------------------------------------------------------------------
 * getters
 */
- (NSString *) api_key {
  return api_key;
}

- (NSString *) shared_secret {
  return shared_secret;
}

- (NSString *) frob {
  return frob;
}

- (NSString *) token {
  return token;
}

- (NSString *) name {
  return name;
}

/* -------------------------------------------------------------------
 * setters
 */
- (void) setApi_key:(NSString *)str {
  [self updateDB:@"api_key" val:str];
  api_key = str;
}

- (void) setShared_secret:(NSString *)str {
  [self updateDB:@"shared_secret" val:str];
  shared_secret = str;
}

- (void) setFrob:(NSString *)str {
  [self updateDB:@"frob" val:str];
  frob = str;
}

- (void) setToken:(NSString *)str {
  [self updateDB:@"token" val:str];
  token = str;
}

- (void) setName:(NSString *)str {
  [self updateDB:@"name" val:str];
  name = str;
}

@end
