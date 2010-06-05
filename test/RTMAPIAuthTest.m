//
//  RTMAPIAuthTest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI+Auth.h"
#import "RTMAPI.h"
#import "PrivateInfo.h"

#define TEST_FROB @"ec1d083b2e10b554e6c90487328d65ba9312d6e5"

@interface RTMAPIAuthTest : SenTestCase
{
   RTMAPI *api;
}
@end

@implementation RTMAPIAuthTest

- (void)setUp
{
   api = [[RTMAPI alloc] init];
}

- (void)tearDown
{
   [api release];
}

- (void)testGetFrob
{
	NSString *frob = [api getFrob];
	STAssertNotNil(frob, @"frob should be acquired.");
	NSLog(@"frob = %@", frob);
}

- (void)_testGetToken
{
	NSString *frob = [api getFrob];
   NSLog(@"frob for getToken: %@", frob);
   NSString *url = [api authURL:frob forPermission:@"read"];
   NSLog(@"auth URL = %@", url);
    
   // interruption: authenticate by the URL

   NSString *token = [api getToken:frob];
	STAssertNotNil(token, @"token should be acquired.");
	NSLog(@"token = %@", token);
}
   
- (void)testCheckToken
{
	STAssertThrows([api checkToken:@"invalid token"], @"token should not be valid");
	STAssertNoThrow([api checkToken:RTM_TOKEN_R], nil);
}

/*
 * helper method to retrieve token
 */
#define GET_TOKEN_URL 1
- (void)_testGetDeleteToken
{
#ifdef GET_TOKEN_URL
	NSString *frob = [api getFrob];
   NSLog(@"frob for getToken: %@", frob);
   NSString *url = [api authURL:frob forPermission:@"delete"];
   NSLog(@"auth URL = %@", url);
   
   // interruption: authenticate by the URL
#else
   NSString *token = [api getToken:@"3482ff73941e916d4e91d97f29534103ed671e8c"];
	STAssertNotNil(token, @"token should be acquired.");
	NSLog(@"token for delete = %@", token);
#endif
}

@end