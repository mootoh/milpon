//
//  RTMAPI.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "RTMAPI.h"
#import "logger.h"
#import "PrivateInfo.h"

#define MP_RTM_URI   "http://api.rememberthemilk.com"
#define MP_REST_PATH "/services/rest/"
#define MP_AUTH_PATH "/services/auth/"

@interface RTMAPI (Private)
/**
 * construct request path.
 */
- (NSString *) path:(NSString *)method withArgs:(NSDictionary *)args;
/**
 * sign a request.
 */
- (NSString *) sign:(NSString *)method withArgs:(NSDictionary *)args;
@end

@implementation RTMAPI (Private)

- (NSString *) path:(NSString *)method withArgs:(NSDictionary *)args
{
   NSMutableString                 *arg = [NSMutableString string];
   NSMutableDictionary *args_with_token = [NSMutableDictionary dictionaryWithDictionary:args];
   if (token)
      [args_with_token setObject:token forKey:@"auth_token"];
   
   NSEnumerator *enumerator = [args_with_token keyEnumerator];
   NSString *key;
   while (key = [enumerator nextObject]) {
      // escape values
      id v = [args_with_token objectForKey:key];
      NSString *val = [v isKindOfClass:[NSString class]] ? v : [v stringValue];
      val = [val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // TODO
      val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

      [arg appendFormat:@"&%@=%@", key, val];
   }

   NSString *sig = [self sign:method withArgs:args_with_token];
   NSString *ret = [NSString
                    stringWithFormat:@"%s%s?method=%@&api_key=%@&api_sig=%@%@",
                    MP_RTM_URI, MP_REST_PATH, method, RTM_API_KEY, sig, arg];
   return ret;
}

- (NSString *)sign:(NSString *)method withArgs:(NSDictionary *)args
{
   // append method, api_key
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:args];
   if (method) [params setObject:method forKey:@"method"];
   
   [params setObject:RTM_API_KEY forKey:@"api_key"];
   
   NSMutableArray *keys = [NSMutableArray arrayWithArray:[params allKeys]];
   [keys sortUsingSelector:@selector(compare:)];
   
   NSString *key;
   NSMutableString *concat = [NSMutableString stringWithString:RTM_SHARED_SECRET];
   for (key in keys)
      [concat appendFormat:@"%@%@", key, [params objectForKey:key]];
   
   // MD5 hash
   unsigned char digest[CC_MD5_DIGEST_LENGTH];
   memset(digest, 0, CC_MD5_DIGEST_LENGTH);
   const char *from = [concat UTF8String];
   CC_MD5(from, strlen(from), digest);
   NSString *ret = [NSString stringWithFormat:
                    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    digest[0], digest[1], digest[2], digest[3],
                    digest[4], digest[5], digest[6], digest[7],
                    digest[8], digest[9], digest[10], digest[11],
                    digest[12], digest[13], digest[14], digest[15]];
   return ret;
}

@end

@implementation RTMAPI

@synthesize token;

- (id) init
{
   if (self = [super init]) {
      self.token = [[NSUserDefaults standardUserDefaults] stringForKey:@"RTM token"];
   }
   return self;
}

- (void) dealloc
{
   [token release];
   [timeline release];
   [super dealloc];
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

- (NSData *) call:(NSString *)method withArgs:(NSDictionary *)args
{
#ifdef LOCAL_DEBUG
   NSString *path = [self resultXMLPath:method];
   return [NSData dataWithContentsOfFile:path];
#else // LOCAL_DEBUG
   //sleep(1);
   NSString *url = [self path:method withArgs:args];
   NSURLRequest *req = [NSURLRequest
      requestWithURL:[NSURL URLWithString:url]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:60.0];
   NSURLResponse *res;
   NSError *err;

   LOG(@"API calling for url=%@", url);
   NSData *ret = [NSURLConnection sendSynchronousRequest:req
      returningResponse:&res
      error:&err];
   if (NULL == ret) {
      LOG(@"failed in API call: %@, url=%@", [err localizedDescription], url);
   } else {
      LOG(@"API call succeeded for url=%@", url);
   }

//#define DUMP_API_RESPONSE
#ifdef DUMP_API_RESPONSE
   if (ret) {
      //NSString *dump_path = [NSString stringWithFormat:@"/tmp/%@.xml", method];
      //BOOL wrote = [ret writeToFile:dump_path options:NSAtomicWrite error:nil];
      //NSAssert(wrote, @"dump should be written");
      LOG(@"method=%@, response=%@", method, [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
   }
#endif // DUMP_API_RESPONSE
   return ret;
#endif // LOCAL_DEBUG
}

// XXX: dup with path:
- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm
{
   NSArray *keys = [NSArray arrayWithObjects:@"frob", @"perms", nil];
   NSArray *vals = [NSArray arrayWithObjects:frob, perm, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSMutableString *arg = [NSMutableString string];
   NSEnumerator *enumerator = [args keyEnumerator];
   NSString *key;
   while (key = [enumerator nextObject])
      [arg appendFormat:@"&%@=%@", key, [args objectForKey:key]];

   NSString *sig = [self sign:nil withArgs:args];
   NSString *ret = [NSString stringWithFormat:@"%s%s?api_key=%@%@&api_sig=%@",
            MP_RTM_URI, MP_AUTH_PATH, RTM_API_KEY, arg, sig];
   return ret;
}

#ifdef LOCAL_DEBUG
const static NSString *s_fake_timeline = @"fake timeline";
#endif // LOCAL_DEBUG

- (NSString *) createTimeline
{
#ifdef LOCAL_DEBUG
   return (NSString *)s_fake_timeline;
#endif // LOCAL_DEBUG

   NSData *response = [self call:@"rtm.timelines.create" withArgs:nil];
   if (! response) return nil;

   method_ = MP_TIMELINES_CREATE;
   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
   [parser setDelegate:self];
   BOOL parsed = [parser parse];
   NSAssert(parsed, @"parse should be done successfully");
   [parser release];

   return timeline;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"timeline"])
      NSAssert(method_ == MP_TIMELINES_CREATE, @"method should be timelines.create");
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"timeline"]) {
      NSAssert(method_ == MP_TIMELINES_CREATE, @"method should be timelines.create");
      NSAssert(timeline, @"timeline should be obtained");
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   [timeline release];
   timeline = [chars retain];
}

@end