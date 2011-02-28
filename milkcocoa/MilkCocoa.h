#import <UIKit/UIKit.h>
#import "MCRequest.h"

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

@interface MilkCocoa : NSObject
@end // MilkCocoa


@interface MilkCocoa (Test)

+ (void) echo:(void (^)(NSError *error, NSDictionary *result))callback;

@end // Test


@interface MilkCocoa (List)

+ (void) getList:(void (^)(NSError *error, NSArray *lists))callback;

@end // List


@interface MilkCocoa (Auth)

+ (void) checkToken:(NSString *)token callback:(void (^)(NSError *error, BOOL isValid))callback;
+ (void) getFrob:(void (^)(NSError *error, NSString *frob))callback;
+ (void) getToken:(NSString *)frob callback:(void (^)(NSError *error, NSString *frob))callback;

@end // Auth

// vim:set expandtab:sw=3:
