//
//  MilkcCocoa.h
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/**
 * Base class for requesting RTM REST APIs.
 * http://www.rememberthemilk.com/services/api/methods/
 */
@interface MCRequest : NSObject <NSXMLParserDelegate>
{
   NSString *token;

   void (^callbackBlock)(NSError *error, NSString *result);

   // for XML Parser
   NSString *echoResult;
   BOOL succeeded;
   NSMutableDictionary *response;
   NSError *error;
   NSString *currentKey, *currentValue;
}

- (id) initWithToken:(NSString *)token;

- (void) echo:(void (^)(NSError *error, NSString *result))block;

@end // MCRequest


/**
 * Communication hub for API requests and the server responses.
 */
@interface MCCenter : NSObject
{
}

- (void) addRequst:(MCRequest *)request;

@end