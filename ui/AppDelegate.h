//
//  AppDelegate.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

#import "RTMSynchronizer.h"

@class RTMAuth;
@class ProgressView;
@class RefreshingViewController;
@protocol RTMSynchronizerDelegate;

@interface AppDelegate : NSObject <UIApplicationDelegate, RTMSynchronizerDelegate>
{	
   IBOutlet UIWindow               *window;
   IBOutlet UINavigationController *navigationController;
   RTMAuth                         *auth;
   RTMSynchronizer                 *syncer;
   ProgressView                    *progressView;
   UIImageView                     *arrowImageView;
   RefreshingViewController        *refreshingViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RTMAuth *auth;
@property (nonatomic, readonly) RTMSynchronizer *syncer;

- (IBAction) addTask;
- (IBAction) update;
- (IBAction) replaceAll;

- (void) showArrow;
- (void) hideArrow;
@end