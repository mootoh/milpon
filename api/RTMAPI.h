//
//  RTMAPI.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * access to RTM Web API.
 */
@interface RTMAPI : NSObject
{
   NSString *token;

   enum {
      MP_TIMELINES_CREATE
   } method_;

   NSString *timeline; //!< for parser
}

@property (nonatomic, retain) NSString *token;

/**
 * call RTM API method with args.
 *
 * if error happened in HTTP request, returns nil.
 */
- (NSData *) call:(NSString *)method withArgs:(NSDictionary *)args;
/**
 * construct authentication URL.
 */
- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm;
/**
 * call RTM API 'rtm.timelines.create'.
 */
- (NSString *) createTimeline;

@end