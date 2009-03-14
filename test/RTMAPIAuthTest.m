//
//  RTMAPIAuthTest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPIAuth.h"
#import "RTMAPI.h"
#import "RTMAuth.h"

#define TEST_FROB @"ec1d083b2e10b554e6c90487328d65ba9312d6e5"

@interface RTMAPIAuthTest : SenTestCase {
  RTMAuth *auth;
  RTMAPI *api;
}
@end

@implementation RTMAPIAuthTest

- (void) setUp
{
  auth = [[RTMAuth alloc] init];
  api  = [[RTMAPI alloc] init];
  [RTMAPI setApiKey:auth.api_key];
  [RTMAPI setSecret:auth.shared_secret];
  [RTMAPI setToken:auth.token];
}

- (void) tearDown
{
  [api release];
  [auth release];
}

- (void) testCheckToken
{
	RTMAPIAuth *api_auth = [[[RTMAPIAuth alloc] init] autorelease];
	STAssertTrue([api_auth checkToken:auth.token], @"token should be valid");
}

- (void) not_testGetFrob
{
	RTMAPIAuth *api_auth = [[[RTMAPIAuth alloc] init] autorelease];
	NSString *frob = [api_auth getFrob];
	STAssertNotNil(frob, @"frob should be acquired.");
	NSLog(@"frob = %@", frob);
}

- (void) not_testGetToken
{
	RTMAPIAuth *api_auth = [[[RTMAPIAuth alloc] init] autorelease];
	NSString *token = [api_auth getToken:TEST_FROB];
	STAssertNotNil(token, @"token should be acquired.");
	NSLog(@"token = %@", token);
}

@end
