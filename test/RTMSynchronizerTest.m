//
//  RTMSynchronizerTest.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMSynchronizer.h"
#import "RTMAPI.h"
#import "RTMDatabase.h"
#import "RTMAuth.h"
#import "RTMList.h"

@interface RTMSynchronizerTest : SenTestCase {
  RTMDatabase *db;
  RTMAuth *auth;
}
@end
	
@implementation RTMSynchronizerTest

- (void) setUp {
  db   = [[RTMDatabase alloc] init];
  auth = [[RTMAuth alloc] initWithDB:db];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
  [RTMAPI setToken:auth.token];
}

- (void) tearDown {
  [auth release];
  [db release];
}

- (void) testReplaceLists {
	RTMSynchronizer *sync = [[[RTMSynchronizer alloc] initWithDB:db withAuth:auth] autorelease];
	[sync replaceLists];
  NSArray *lists = [RTMList allLists:db];
  STAssertTrue(5 == [lists count], @"check 5 lists exist");
}

- (void) testSyncLists {
  // erase all lists
  [RTMList erase:db];

  // create 1 list
  NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", nil];
  NSArray *vals = [NSArray arrayWithObjects:@"777", @"lucky seven", nil];
  NSDictionary *params = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
  [RTMList create:params inDB:db];

  // sync
	RTMSynchronizer *sync = [[[RTMSynchronizer alloc] initWithDB:db withAuth:auth] autorelease];
	[sync syncLists];

  // check lists are synchronized
  NSArray *lists = [RTMList allLists:db];
  STAssertTrue(5 == [lists count], @"check 5 lists exist");
}

- (void) testReplaceTasks {
	RTMSynchronizer *sync = [[[RTMSynchronizer alloc] initWithDB:db withAuth:auth] autorelease];
	[sync replaceTasks];
  /*
  NSArray *lists = [RTMList allLists:db];
  STAssertTrue(5 == [lists count], @"check 5 lists exist");
  */
}
@end
