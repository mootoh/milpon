//
//  RTMAPIAuth.m
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAPIXMLParserCallback.h"
#import "logger.h"

/* -------------------------------------------------------------------
 * CheckTokenCallback
 */
@interface CheckTokenCallback : RTMAPIXMLParserCallback {
  NSString *token;
}
@property (nonatomic, retain) NSString *token;
@end	

@implementation CheckTokenCallback
@synthesize token;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
  self.token = chars;
  [parser abortParsing];
}
@end

/* -------------------------------------------------------------------
 * GetFrobCallback
 */
@interface GetFrobCallback : RTMAPIXMLParserCallback {
  NSString *frob;
}
@property (nonatomic, retain) NSString *frob;
@end	

@implementation GetFrobCallback
@synthesize frob;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
  self.frob = chars;
  [parser abortParsing];
}
@end

/* -------------------------------------------------------------------
 * GetTokenCallback
 */
@interface GetTokenCallback : RTMAPIXMLParserCallback {
  NSString *token;
}
@property (nonatomic, retain) NSString *token;
@end	

@implementation GetTokenCallback
@synthesize token;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
  self.token = [chars retain];
  [parser abortParsing];
}
@end

/* -------------------------------------------------------------------
 * RTMAPIAuth
 */
@implementation RTMAPIAuth

- (BOOL) checkToken:(NSString *)token
{
  RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
  NSDictionary *args = [NSDictionary dictionaryWithObject:token forKey:@"auth_token"];
  NSData *ret = [api call:@"rtm.auth.checkToken" withArgs:args];
  if (! ret) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
  CheckTokenCallback *cb = [[[CheckTokenCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    LOG(@"checkToken failed : %@", [cb.error localizedDescription]);
    return NO;
  }
#ifdef LOCAL_DEBUG
  return YES;
#else // LOCAL_DEBUG
  return [token isEqualToString:cb.token];
#endif // LOCAL_DEBUG
}

- (NSString *) getFrob
{
  RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
  NSData *ret = [api call:@"rtm.auth.getFrob" withArgs:nil];
  if (! ret) return nil;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
  GetFrobCallback *cb = [[[GetFrobCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"getFrob failed : %@", [cb.error localizedDescription]);
    return nil;
  }
  return cb.frob;
}

- (NSString *) getToken:(NSString *)frob
{
  RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
  NSDictionary *args = [NSDictionary dictionaryWithObject:frob forKey:@"frob"];
  NSData *ret = [api call:@"rtm.auth.getToken" withArgs:args];
  if (! ret) return nil;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
  GetTokenCallback *cb = [[[GetTokenCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"getToken failed : %@", [cb.error localizedDescription]);
    return nil;
  }
  return cb.token;
}

@end // RTMAuth
