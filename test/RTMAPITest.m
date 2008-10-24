//
//  RTMAPITest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "MockRTMAPI.h"
#import "RTMDatabase.h"
#import "RTMAuth.h"
#import "RTMAPIXMLParserCallback.h"

#define TEST_FROB @"ec1d083b2e10b554e6c90487328d65ba9312d6e5"

/* -------------------------------------------------------------------
 * RTMAPITest
 */
@interface RTMAPITest : SenTestCase {
  RTMDatabase *db;
  RTMAuth *auth;
  RTMAPI *api;
}
@end

@implementation RTMAPITest

- (void) setUp {
  db   = [[RTMDatabase alloc] init];
  auth = [[RTMAuth alloc] initWithDB:db];
  api  = [[RTMAPI alloc] init];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
  [RTMAPI setToken:auth.token];
}

- (void) tearDown {
  [api release];
  [auth release];
  [db release];
}

- (void) testCall {
	NSArray *keys = [NSArray arrayWithObjects:@"one", @"two", nil];
	NSArray *vals = [NSArray arrayWithObjects:@"1", @"2", nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals
													 forKeys:keys];
	
	NSData *ret = [api call:@"rtm.test.echo" withArgs:args];
  NSLog(@"test.echo returns %@", [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
  RTMAPIXMLParserCallback *callback = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:callback];
  [parser parse];
  STAssertTrue(callback.succeeded, @"check call");
  STAssertNil(callback.error, @"check call");
}

- (void) testError {
	NSArray *keys = [NSArray arrayWithObjects:@"one", @"two", nil];
	NSArray *vals = [NSArray arrayWithObjects:@"1", @"2", nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals
                                                   forKeys:keys];
	
	NSData *ret = [api call:@"rtm.test.echoException" withArgs:args];
  NSLog(@"test.echo returns %@", [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
  RTMAPIXMLParserCallback *callback = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:callback];
  [parser parse];
  STAssertFalse(callback.succeeded, @"api request should fail in invalid method.");
  STAssertNotNil(callback.error, @"error should be set");
  NSLog(@"error = %@", [callback.error localizedDescription]);
}
  
- (void) not_testAuthURL {
	NSString *url = [api authURL:TEST_FROB forPermission:@"delete"];
	STAssertNotNil(url, @"check auth url");
	NSLog(@"auth url = %@", url);
}

- (void) testCreateTimeline {
	NSString *timeline = [api createTimeline];
	STAssertNotNil(timeline, @"check timeline");
	NSLog(@"timeline = %@", timeline);
}
@end
