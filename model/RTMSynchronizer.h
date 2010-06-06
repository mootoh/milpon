//
//  RTMSynchronizer.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMAPI;
@class ProgressView;

@protocol RTMSynchronizerDelegate

- (void) didReplaceAll;
- (void) didUpdate;

@end

@interface RTMSynchronizer : NSObject {
   RTMAPI                      *api;
   NSString                    *timeLine;
   id <RTMSynchronizerDelegate> delegate;
}

@property (nonatomic, retain) NSString *timeLine;
@property (nonatomic, retain) id <RTMSynchronizerDelegate> delegate;

- (id) initWithAPI:(RTMAPI *)api;

- (void) replaceAll;
- (void) update:(ProgressView *)progressView;;

- (void) replaceLists;
/**
 * @todo TODO: sync list name
 */
- (void) syncLists;

- (void) replaceTasks;
- (void) syncTasks:(ProgressView *)progressView;
- (void) uploadPendingTasks:(ProgressView *)progressView;
- (void) syncModifiedTasks:(ProgressView *)progressView;

- (BOOL) is_reachable;

@end