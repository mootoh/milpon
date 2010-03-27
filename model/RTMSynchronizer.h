//
//  RTMSynchronizer.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMAuth;
@class ProgressView;

@protocol RTMSynchronizerDelegate

- (void) didReplaceAll;
- (void) didUpdate;

@end

@interface RTMSynchronizer : NSObject {
   RTMAuth *auth;
   NSString *timeLine;
   id <RTMSynchronizerDelegate> delegate;
}

@property (nonatomic, retain) NSString *timeLine;
@property (nonatomic, retain) id <RTMSynchronizerDelegate> delegate;

- (id) initWithAuth:(RTMAuth *)aauth;

- (void) replaceAll;
- (void) update;

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