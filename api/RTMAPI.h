//
//  RTMAPI.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTMAPIDelegate

- (id) result;

@end

/**
 * access to RTM Web API.
 */
@interface RTMAPI : NSObject <RTMAPIDelegate>
{
   NSString *token;
   NSString *timeline; //!< for parser
}

@property (nonatomic, retain) NSString *token;

/**
 * call RTM API method with args.
 *
 * if error happened in HTTP request, returns nil.
 */
- (NSData *) call:(NSString *)method args:(NSDictionary *)args;

/**
 * @param delegate XMLParser delegate
 */
- (id) call:(NSString *)method args:(NSDictionary *)args withDelegate:(id <RTMAPIDelegate>)delegate;

/**
 * construct authentication URL.
 */
- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm;
/**
 * @brief call RTM API 'rtm.timelines.create'.
 * @note  this method is not reentrant.
 */
- (NSString *) createTimeline;

@end