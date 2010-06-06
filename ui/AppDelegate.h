//
//  AppDelegate.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

#import "RTMSynchronizer.h"

@class RTMAPI;
@class ProgressView;
@class RefreshingViewController;
@protocol RTMSynchronizerDelegate;

#pragma mark -
@interface AppDelegate : NSObject <UIApplicationDelegate, RTMSynchronizerDelegate>
{	
   IBOutlet UIWindow               *window;
   IBOutlet UINavigationController *navigationController;
   RTMAPI                          *api;
   RTMSynchronizer                 *syncer;
   ProgressView                    *progressView;
   UIImageView                     *arrowImageView;
   RefreshingViewController        *refreshingViewController;
}

@property (nonatomic, retain)   UIWindow        *window;
@property (nonatomic, readonly) RTMSynchronizer *syncer;
@property (nonatomic, readonly) RTMAPI          *api;

- (IBAction) addTask;
- (IBAction) update;
- (IBAction) replaceAll;

- (void) showArrow;
- (void) hideArrow;
@end