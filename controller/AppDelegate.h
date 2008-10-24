//
//  AppDelegate.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright deadbeaf.org 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMAuth;
@class RTMDatabase;

@interface AppDelegate : NSObject <UIApplicationDelegate> {	
  IBOutlet UIWindow *window;
  RTMAuth *auth;
  RTMDatabase *db;
  NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) RTMAuth *auth;
@property (nonatomic, readonly) RTMDatabase *db;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end
