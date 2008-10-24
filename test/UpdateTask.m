//
//  UpdateTask
//  Milpon
//
//  Created by mootoh on 9/17/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "RTMDatabase.h"
#import "RTMAPIList.h"
#import "RTMAPITask.h"
#import "RTMAuth.h"

@interface UpdateTask : SenTestCase {
  RTMAuth *auth;
}
@end	

@implementation UpdateTask

- (void) setUp {
  auth = [[RTMAuth alloc] init];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
}

- (void) tearDown {
  [auth release];
}

- (void) _test_001_EraseDB {
  [RTMTask erase];
}

- (void) _test_002_EraseAndDownload {
  [RTMTask erase];

  RTMAPIList *lst_api = [[[RTMAPIList alloc] init] autorelease];
  NSArray *lists = [lst_api getList:auth.token];
  NSAssert([lists count] > 0, @"list should not be empty");

  RTMAPITask *tsk_api = [[[RTMAPITask alloc] init] autorelease];

  RTMList *lst;
  for (lst in lists) {    
    [tsk_api getList:auth.token forListID:[NSString stringWithFormat:@"%d", [lst iD]]];
    NSArray *tasks = [RTMTask tasksInList:lst.iD];
    
    NSAssert(tasks, @"tasks");
    NSLog(@"tasks count = %d", [tasks count]);
  }
}

- (void) test_004_EraseAndDownloadAndSaveToDB {
  [RTMTask erase];
  
  RTMAPITask *tsk_api = [[[RTMAPITask alloc] init] autorelease];
  
  [tsk_api getList:auth.token];
  NSArray *tasks = [RTMTask allTasks];

  RTMTask *tsk;
  for (tsk in tasks) {
    NSLog(@"tsk name = %@", tsk.name);
    //[tsk save];
  }
}

#if 0
- (void) _test_005_delete_tested_lists {
  RTMDatabase *db = [[[RTMDatabase alloc] init] autorelease];
  [RTMList eraseDB:db];

  RTMAPIList *api_lst = [[[RTMAPIList alloc] init] autorelease];
  NSArray *lists = [api_lst getList:TEST_TOKEN_D];
  NSAssert([lists count] > 0, @"list should not be empty");
  
  RTMList *lst;
  for (lst in lists) {
    [api_lst delete:[NSString stringWithFormat:@"%d", [lst iD]] withToken:TEST_TOKEN_D];
  }
  
}
#endif // 0
@end
