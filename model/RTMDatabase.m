//
//  RTMDatabase.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMDatabase.h"

@interface RTMDatabase (Private)
- (NSString *) databasePath;
@end


@implementation RTMDatabase

@synthesize handle, path;

-(id) init
{
  if (self = [super init]) {
    path = [[self databasePath] retain];
    if (SQLITE_OK == sqlite3_open([path UTF8String], &handle)) {
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

@end
