//
//  RTMAPI.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMAPIParserDelegate.h"

/**
 * access to the RTM REST API.
 */
@interface RTMAPI : NSObject
{
   NSString *token;
}

@property (nonatomic, retain) NSString *token;

/**
 * synchronous call with delegate, wrapper for call:args.
 * @param delegate XMLParser delegate
 */
- (id) call:(NSString *)method args:(NSDictionary *)args withDelegate:(RTMAPIParserDelegate *)delegate;

/**
 * construct authentication URL.
 */
- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm;

@end