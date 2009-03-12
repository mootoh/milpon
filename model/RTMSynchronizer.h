//
//  RTMSynchronizer.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMAuth;
@class ProgressView;

@interface RTMSynchronizer : NSObject {
  RTMAuth *auth;
}

- (id) init:(RTMAuth *)aauth;

- (void) replaceLists;
/**
 * @todo TODO: sync list name
 */
- (void) syncLists;

- (void) replaceTasks;
- (void) syncTasks:(ProgressView *)progressView;
- (void) uploadPendingTasks:(ProgressView *)progressView;
- (void) syncModifiedTasks:(ProgressView *)ProgressView;

@end
