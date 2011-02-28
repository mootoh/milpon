#import <CommonCrypto/CommonDigest.h>
#import "MCParserDelegate.h"
#import "PrivateInfo.h"
#import "MCLog.h"

#define MP_RTM_URI   "http://api.rememberthemilk.com"
#define MP_REST_PATH "/services/rest/"
#define MP_AUTH_PATH "/services/auth/"

#pragma mark Private
@interface MCRequest (Private)

- (NSString *) constructRequestPath;
- (NSString *) signRequest:(NSDictionary *)args;
+ (NSString *) signRequest:(NSDictionary *)args;

@end // MCRequest (Private)


#pragma mark Public

@implementation MCRequest

- (id) initWithToken:(NSString *)tkn method:(NSString *)mtd parameters:(NSDictionary *)params parserDelegate:(id <NSXMLParserDelegate, MCXMLParserDelegate>) delegate callback:(void (^)(NSError *error, id result))cb
{
   if (self = [super init]) {
      token = tkn ? [tkn copy] : nil;
      parameters = params ?
         [[NSMutableDictionary alloc] initWithDictionary:params] :
         [[NSMutableDictionary alloc] init];
      method = [mtd copy];
      callbackBlock = [cb copy];
      xmlParserDelegate = [delegate retain];
   }
   return self;
}

- (void) dealloc
{
   [xmlParserDelegate release];
   [callbackBlock release];
   [method release];
   [parameters release];
   [token release];
   [super dealloc];
}

- (void) send
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSString *urlString = [self constructRequestPath];
   NSURLRequest   *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:60.0];

   MCLOG(@"url = %@", urlString);

   NSError *error = nil;
   NSURLResponse *response = nil;
   NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
   if (NULL == data)
      [NSException raise:@"ConnectionError" format:@"failed in API call: %@, url=%@", [error localizedDescription], urlString];

#ifdef DUMP_API_RESPONSE
   //NSString *dump_path = [NSString stringWithFormat:@"/tmp/%@.xml", method];
   //BOOL wrote = [ret writeToFile:dump_path options:NSAtomicWrite error:nil];
   //NSAssert(wrote, @"dump should be written");
   MCLOG(@"method=%@, response=%@", method, [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
#endif // DUMP_API_RESPONSE

   MCLOG(@"<<<<<<<<<\n%@\n>>>>>>>>>", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);

   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
   parser.delegate = xmlParserDelegate;

   if ([parser parse]) { // succeeded in parsing
      MCLOG(@"parse end");
      callbackBlock(nil, [xmlParserDelegate response]);
   } else {
      MCLOG(@"parse error");
      NSInteger errCode = [[parser parserError] code];
      if (errCode == NSXMLParserInternalError || errCode == NSXMLParserDelegateAbortedParseError)
         // rsp error
         callbackBlock([xmlParserDelegate error], nil);
      else
         callbackBlock([parser parserError], nil);
   }

   parser.delegate = nil;
   [parser release];

//   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
//   [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//   [connection start];
   [pool release];
}


#if 0
#pragma mark -
#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   MCLOG(@"didReceiveData:%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);

   NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
   parser.delegate = xmlParserDelegate;

   if ([parser parse]) { // succeeded in parsing
      callbackBlock(nil, [xmlParserDelegate response]);
   } else {
      NSInteger errCode = [[parser parserError] code];
      if (errCode == NSXMLParserInternalError || errCode == NSXMLParserDelegateAbortedParseError)
         // rsp error
         callbackBlock([xmlParserDelegate error], nil);
      else
         callbackBlock([parser parserError], nil);
   }

   parser.delegate = nil;
   [parser release];
}
#endif // 0

// XXX: dup with path:
+ (NSString *) authURL:(NSString *)frob permission:(NSString *)perm
{
   NSArray      *keys = [NSArray arrayWithObjects:@"frob", @"perms", nil];
   NSArray      *vals = [NSArray arrayWithObjects:frob, perm, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   NSString *arg = @"";
   for (NSString *key in args)
      arg = [arg stringByAppendingFormat:@"&%@=%@", key, [args objectForKey:key]];
   
   NSString *sig = [MCRequest signRequest:args];
   return [NSString stringWithFormat:@"%s%s?api_key=%@%@&api_sig=%@", MP_RTM_URI, MP_AUTH_PATH, RTM_API_KEY, arg, sig];
}

@end // MCRequest

#pragma mark Private

@implementation MCRequest (Private)

+ (NSString *) signRequest:(NSDictionary *)args
{
   NSMutableArray *keys = [NSMutableArray arrayWithArray:[args allKeys]];
   [keys sortUsingSelector:@selector(compare:)];

   NSMutableString *concat = [NSMutableString stringWithString:RTM_SHARED_SECRET];
   for (NSString *key in keys)
      [concat appendFormat:@"%@%@", key, [args objectForKey:key]];

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

- (NSString *) signRequest:(NSDictionary *)args
{
   // append method, api_key
   NSMutableDictionary *mutableArgs = [NSMutableDictionary dictionaryWithDictionary:args];
   [mutableArgs setObject:method forKey:@"method"];
   [mutableArgs setObject:RTM_API_KEY forKey:@"api_key"];

   return [MCRequest signRequest:mutableArgs];
}

- (NSString *) escape:(NSString *) src
{
   // escape values
   NSString *dst = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // TODO
   dst = [dst stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
   return dst;
}

- (NSString *) pairString:(NSDictionary *)args
{
   NSMutableString *arg = [NSMutableString string];
   for (id key in args) {
      id          v = [args objectForKey:key];
      NSString *val = [v isKindOfClass:[NSString class]] ? v : [v stringValue];

      val = [self escape:val];
      [arg appendFormat:@"&%@=%@", key, val];
   }
   return arg;
}

- (NSString *) constructRequestPath
{
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:parameters];
   if (token)
      [args setObject:token forKey:@"auth_token"];

   NSString *arg = [self pairString:args];
   NSString *sig = [self signRequest:args];
   return [NSString stringWithFormat:@"%s%s?method=%@&api_key=%@&api_sig=%@%@", MP_RTM_URI, MP_REST_PATH, method, RTM_API_KEY, sig, arg];
}

@end // MCRequest (Private)


@implementation MCCenter

static MCCenter *s_instance = nil;

+ (MCCenter *) defaultCenter
{
   if (s_instance == nil)
      s_instance = [[MCCenter alloc] init];

   return s_instance;
}

- (id) init
{
   if (self = [super init]) {
      requestQueue = [[NSOperationQueue alloc] init];
   }
   return self;
}

- (void) dealloc
{
   [requestQueue release];
   [super dealloc];
}

- (void) addRequst:(MCRequest *)request
{
   [requestQueue addOperationWithBlock:^{
      [request retain];
#ifdef UNIT_TEST
      [request send];
#else
      [request performSelectorOnMainThread:@selector(send) withObject:nil waitUntilDone:YES];
#endif
      [request release];
   }];
}

@end // MCCenter

#if 0

// -----------------------------------------------------------------------------------
- (id) init
{
   if (self = [super init]) {
#ifdef DEBUG
      self.token = RTM_TOKEN_D;
#else // DEBUG
      self.token = [[NSUserDefaults standardUserDefaults] stringForKey:k_RTM_TOKEN_KEY];
#endif // DEBUG
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

#endif // 0