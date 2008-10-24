//
//  UpdateList
//  Milpon
//
//  Created by mootoh on 9/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMList.h"
#import "RTMDatabase.h"
#import "RTMAPIList.h"
#import "RTMAuth.h"

@interface UpdateList : SenTestCase {
  RTMDatabase *db;
  RTMAuth *auth;
}
@end

@implementation UpdateList

- (void) setUp {
  db = [[RTMDatabase alloc] init];
  auth = [[RTMAuth alloc] init];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
}

- (void) tearDown {
  [auth release];
  [db release];
}

- (void) test_002_EraseDB {
  [RTMList erase];
}

- (void) _test_003_EraseAndDownload {
  [RTMList erase];
  
  RTMAPIList *lst = [[[RTMAPIList alloc] init] autorelease];
  NSArray *lists = [lst getList:auth.token];
  NSAssert([lists count] > 0, @"list should not be empty");
}

- (void) test_004_EraseAndDownloadAndSaveToDB {
  NSLog(@"db path = %@", [db path]);

  [RTMList erase];

  RTMAPIList *api_lst = [[[RTMAPIList alloc] init] autorelease];
  NSArray *lists = [api_lst getList:auth.token];
  NSAssert([lists count] > 0, @"list should not be empty");
  
  RTMList *lst;
  for (lst in lists) {
    [lst save];
  }
}

- (void) _test_005_delete_tested_lists {
  [RTMList erase];

  RTMAPIList *api_lst = [[[RTMAPIList alloc] init] autorelease];
  NSArray *lists = [api_lst getList:auth.token];
  NSAssert([lists count] > 0, @"list should not be empty");
  
  RTMList *lst;
  for (lst in lists) {
    [api_lst delete:[NSString stringWithFormat:@"%d", [lst iD]] withToken:auth.token];
  }  
}

@end
