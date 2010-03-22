//
//  AppDelegate.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

@class RTMAuth;
@class ProgressView;

@interface AppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate>
{	
   IBOutlet UIWindow               *window;
   IBOutlet UINavigationController *navigationController;
   RTMAuth                         *auth;
   ProgressView                    *pv;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RTMAuth *auth;

- (IBAction) addTask;
- (IBAction) saveAuth;
- (IBAction) authDone;

@end