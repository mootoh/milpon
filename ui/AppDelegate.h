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
   UIBarButtonItem                 *refreshButton;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RTMAuth *auth;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;

- (IBAction) addTask;
- (IBAction) saveAuth;
- (IBAction) authDone;
- (IBAction) fetchAll;
- (IBAction) refresh;
- (IBAction) showDialog;
@end