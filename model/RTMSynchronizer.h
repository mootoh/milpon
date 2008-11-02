//
//  RTMSynchronizer.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMDatabase;
@class RTMAuth;
@class ProgressView;

@interface RTMSynchronizer : NSObject {
  RTMDatabase *db_;
  RTMAuth *auth;
}

- (id) initWithDB:(RTMDatabase *)ddb withAuth:aauth;

- (void) replaceLists;
/**
 * @todo TODO: sync list name
 */
- (void) syncLists;

- (void) replaceTasks;
- (void) syncTasks;
- (void) uploadPendingTasks:(ProgressView *)progressView;
- (void) syncCompletedTasks;

@end
