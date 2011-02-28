#import <UIKit/UIKit.h>

@protocol MCXMLParserDelegate

- (id) response;
- (NSError *) error;

@end

/**
 * Base class for requesting RTM REST APIs.
 * http://www.rememberthemilk.com/services/api/methods/
 */
@interface MCRequest : NSObject
{
   NSString *method;
   NSString *token;
   NSMutableDictionary *parameters;
   void (^callbackBlock)(NSError *error, id result);

   id <NSXMLParserDelegate, MCXMLParserDelegate> xmlParserDelegate;
}

- (id) initWithToken:(NSString *)tkn method:(NSString *)mtd parameters:(NSDictionary *)params parserDelegate:(id <NSXMLParserDelegate, MCXMLParserDelegate>) delegate callback:(void (^)(NSError *error, id result))cb;

/**
 * send an API request to RTM asynchronously.
 *
 * callback:
 *   - the response is packed into the dictionary if succeeded.
 *   - if failed, error is set.
 */
- (void) send;

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

@end // MCCenter

// vim:set expandtab:sw=3:
