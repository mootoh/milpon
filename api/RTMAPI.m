//
//  RTMAPI.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "RTMAPI.h"
#import "MPLogger.h"
#import "PrivateInfo.h"

#define MP_RTM_URI   "http://api.rememberthemilk.com"
#define MP_REST_PATH "/services/rest/"
#define MP_AUTH_PATH "/services/auth/"

// -----------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private
@interface RTMAPI (Private)
/**
 * construct request path.
 */
- (NSString *) path:(NSString *)method withArgs:(NSDictionary *)args;
/**
 * sign a request.
 */
- (NSString *) sign:(NSString *)method withArgs:(NSDictionary *)args;

/**
 * synchronous call RTM API method with args.
 *
 * if error happened in HTTP request, returns nil.
 */
- (NSData *) call:(NSString *)method args:(NSDictionary *)args;
@end

@implementation RTMAPI (Private)

- (NSString *)constructwithEscaping:(NSDictionary *)args
{
   NSMutableString *arg = [NSMutableString string];
   for (id key in args) {
      id          v = [args objectForKey:key];
      NSString *val = [v isKindOfClass:[NSString class]] ? v : [v stringValue];

      // escape values
      val = [val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // TODO
      val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
      
      [arg appendFormat:@"&%@=%@", key, val];
   }
   return arg;
}

- (NSString *)path:(NSString *)method withArgs:(NSDictionary *)args
{
   NSMutableDictionary *args_with_token = [NSMutableDictionary dictionaryWithDictionary:args];
   if (token) [args_with_token setObject:token forKey:@"auth_token"];

   NSString *arg = [self constructwithEscaping:args_with_token];
   NSString *sig = [self sign:method withArgs:args_with_token];
   return [NSString stringWithFormat:@"%s%s?method=%@&api_key=%@&api_sig=%@%@", MP_RTM_URI, MP_REST_PATH, method, RTM_API_KEY, sig, arg];
}

- (NSString *)sign:(NSString *)method withArgs:(NSDictionary *)args
{
   // append method, api_key
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:args];
   if (method) [params setObject:method forKey:@"method"];
    [params setObject:RTM_API_KEY forKey:@"api_key"];
   
   NSMutableArray *keys = [NSMutableArray arrayWithArray:[params allKeys]];
   [keys sortUsingSelector:@selector(compare:)];
   
   NSMutableString *concat = [NSMutableString stringWithString:RTM_SHARED_SECRET];
   for (NSString *key in keys)
      [concat appendFormat:@"%@%@", key, [params objectForKey:key]];
   
   // MD5 hash
   unsigned char digest[CC_MD5_DIGEST_LENGTH];
   memset(digest, 0, CC_MD5_DIGEST_LENGTH);
   const char *from = [concat UTF8String];
   CC_MD5(from, strlen(from), digest);
 
   return  [NSString stringWithFormat:
               @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
               digest[0], digest[1], digest[2], digest[3],
               digest[4], digest[5], digest[6], digest[7],
               digest[8], digest[9], digest[10], digest[11],
               digest[12], digest[13], digest[14], digest[15]];
}

- (NSData *) call:(NSString *)method args:(NSDictionary *)args
{
   NSString      *url = [self path:method withArgs:args];
   NSURLRequest  *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0];
   NSURLResponse *res = nil;
   NSError       *err = nil;
   
   LOG(@"API calling for url=%@", url);
   NSData *ret = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
   if (NULL == ret)
      [NSException raise:@"ConnectionError" format:@"failed in API call: %@, url=%@", [err localizedDescription], url];
   
#ifdef DUMP_API_RESPONSE
   //NSString *dump_path = [NSString stringWithFormat:@"/tmp/%@.xml", method];
   //BOOL wrote = [ret writeToFile:dump_path options:NSAtomicWrite error:nil];
   //NSAssert(wrote, @"dump should be written");
   LOG(@"method=%@, response=%@", method, [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
#endif // DUMP_API_RESPONSE

   return ret;
}

@end

// -----------------------------------------------------------------------------------
#pragma mark -
#pragma mark RTMAPI
@implementation RTMAPI

@synthesize token;

#define k_RTM_TOKEN_KEY @"RTM token"

- (id) init
{
   if (self = [super init]) {
      self.token = [[NSUserDefaults standardUserDefaults] stringForKey:k_RTM_TOKEN_KEY];
   }
   return self;
}

- (void) dealloc
{
   [token release];
   [super dealloc];
}

- (void) setToken:(NSString *)tkn
{
   [[NSUserDefaults standardUserDefaults] setObject:tkn forKey:k_RTM_TOKEN_KEY];
   if (token) [token release];
   token = [tkn retain];
}

#ifdef LOCAL_DEBUG
- (NSString *)resultXMLPath:(NSString *)method
{
   NSString *filename = [method stringByAppendingFormat:@".xml"];
   NSFileManager *fm = [NSFileManager defaultManager];
   NSString *doc_dir = @"/tmp";
   NSString *db_path = [doc_dir stringByAppendingPathComponent:filename];

   NSError *error;
   if ([fm fileExistsAtPath:db_path] && ! [fm removeItemAtPath:db_path error:&error]) {
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to remove existing xml file with message '%@' path=%@.", [error localizedDescription], db_path]
         userInfo:nil] raise];
   }

#ifdef TEST
   // path
   NSString *base_path = [fm currentDirectoryPath];
   NSString *path = [base_path stringByAppendingPathComponent:
                     [NSString stringWithFormat:@"/sample/%@", filename]];
#else // TEST
   NSString *base_path = [[NSBundle mainBundle] resourcePath];
   NSString *path = [base_path stringByAppendingPathComponent:
      [NSString stringWithFormat:@"/%@", filename]];
#endif // TEST
   if (! [fm copyItemAtPath:path toPath:db_path error:&error])
      [[NSException
         exceptionWithName:@"file exception"
         reason:[NSString stringWithFormat:@"Failed to copy xml file with message '%@', from=%@, to=%@.", [error localizedDescription], path, db_path]
         userInfo:nil] raise];

   LOG(@"resultXMLPath = %@", path);
   return path;
}
#endif // LOCAL_DEBUG

- (id) call:(NSString *)method args:(NSDictionary *)args delegate:(RTMAPIParserDelegate *)delegate
{
   NSData *response = [self call:method args:args];
   NSAssert(response, @"check response");
   LOG(@"response = %@", [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease]);
   
   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
   parser.delegate = delegate;
   
   NSException *exception = nil;
   
   if (! [parser parse]) {
      NSInteger errCode = [[parser parserError] code];
      if (errCode == NSXMLParserInternalError || errCode == NSXMLParserDelegateAbortedParseError) { // rsp error
         if (delegate.error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:delegate.error forKey:@"error"];
            exception = [NSException exceptionWithName:@"RTMAPIException" reason:[NSString stringWithFormat:@"%d : %@", [delegate.error code], [delegate.error localizedDescription]] userInfo:userInfo];
         }
      } else {         
         NSString *errorString = [[parser parserError] localizedDescription];
         exception = [NSException exceptionWithName:@"APIResponseParserError" reason:[NSString stringWithFormat:@"failed in parse: %@", errorString] userInfo:nil];
      }
   }

   parser.delegate = nil;
   [parser release];
   if (exception) [exception raise];
   return [delegate result];
}

// XXX: dup with path:
- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm
{
   NSArray      *keys = [NSArray arrayWithObjects:@"frob", @"perms", nil];
   NSArray      *vals = [NSArray arrayWithObjects:frob, perm, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSString *arg = @"";
   for (NSString *key in args)
      arg = [arg stringByAppendingFormat:@"&%@=%@", key, [args objectForKey:key]];

   NSString *sig = [self sign:nil withArgs:args];
   return [NSString stringWithFormat:@"%s%s?api_key=%@%@&api_sig=%@", MP_RTM_URI, MP_AUTH_PATH, RTM_API_KEY, arg, sig];
}

@end