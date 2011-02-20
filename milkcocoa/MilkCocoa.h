//
//  MilkcCocoa.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#define k_MC_ERROR_DOMAIN @"MilkCocoa"

enum {
   MC_RTM_INVALID_API_KEY        = 100,
   MC_RTM_ERROR_SERVICE_DOWN     = 105,
   MC_RTM_FORMAT_NOT_FOUND       = 111,
   MC_RTM_METHOD_NOT_FOUND       = 112,
   MC_RTM_INVALID_SOAP_ENVELOPE  = 114,
   MC_INVALID_XMLRPC_METHOD_CALL = 115,
   MC_RTM_STATUS_OK              = 0
};

@class MCParserDelegate;

/**
 * Base class for requesting RTM REST APIs.
 * http://www.rememberthemilk.com/services/api/methods/
 */
@interface MCRequest : NSObject
{
   NSString *token;
   MCParserDelegate *parserDelegate;

   void (^callbackBlock)(NSError *error, NSDictionary *result);
}

/**
 * send an API request to RTM asynchronously.
 *
 * callback:
 *   - the response is packed into the dictionary if succeeded.
 *   - if failed, error is set.
 */
- (void) send:(void (^)(NSError *error, NSDictionary *result))callback;
//- (id) initWithToken:(NSString *)token;
//- (void) echo:(void (^)(NSError *error, NSString *result))block;

@end // MCRequest


/**
 * Communication hub for API requests and the server responses.
 * Main purpose: regulation of the API calls.
 */
@interface MCCenter : NSObject
{
   NSOperationQueue *requestQueue;
}

+ (MCCenter *) defaultCenter;

- (void) addRequst:(MCRequest *)request;

@end
