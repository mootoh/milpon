//
//  RTMAPI.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
   RTM_ERROR_SERVICE_DOWN = 105,
   RTM_STATUS_OK = 0
};

/**
 * Base class for requesting RTM REST APIs.
 * http://www.rememberthemilk.com/services/api/methods/
 */
@interface RTMAPIRequest : NSObject <NSXMLParserDelegate>
{
   NSString *token;

   void (^callbackBlock)(NSInteger statusCode, NSString *result);
   NSString *echoResult;
}

- (id) initWithToken:(NSString *)token;

- (void) echo:(void (^)(NSInteger statusCode, NSString *result))block;

@end // RTMAPIRequest

/**
 * Communication hub for API requests and the server responses.
 */
@interface RTMAPICenter : NSObject
{
}

- (void) addRequst:(RTMAPIRequest *)request;

@end
