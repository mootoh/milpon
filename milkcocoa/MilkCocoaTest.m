//
//  MilkCocoaTest
//  Milpon
//
//  Created by Motohiro Takayama on 2/21/11.
//  Copyright 2011 deadbeaf.org. All rights reserved.
//

#import "MilkCocoaTest.h"
#import "MilkCocoa.h"
#import "PrivateInfo.h"

@implementation MilkCocoaTest
@end

@implementation MilkCocoaTest (Test)

- (void) _testEcho
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MilkCocoa echo:^(NSError *error, NSDictionary *result) {
      STAssertNil(error, @"should be success");

      NSString *method = [result objectForKey:@"method"];
      STAssertTrue([method isEqualToString:@"rtm.test.echo"], [NSString stringWithFormat:@"method check, received:", method]);

      NSString *api_key = [result objectForKey:@"api_key"];
      STAssertNotNil(api_key, @"should be passed a valid api_key");

      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];

   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}

@end

@implementation MilkCocoaTest (Auth)

- (void) _testCheckToken
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   
   [MilkCocoa checkToken:RTM_TOKEN_R callback:^(NSError *error, BOOL isValid) {
      STAssertNil(error, @"should be success");
      
      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
   
   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}

- (void) _testGetFrob
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   
   [MilkCocoa getFrob:^(NSError *error, NSString *frob) {
      STAssertNil(error, @"should be success");
      STAssertNotNil(frob, @"frob should be retrieved");
      
      NSLog(@"frob = %@", frob);
      
      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
   
   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}

- (void) _testAuthURL
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   
   [MilkCocoa getFrob:^(NSError *error, NSString *frob) {
      STAssertNil(error, @"should be success");
      STAssertNotNil(frob, @"frob should be retrieved");
      
      NSLog(@"frob = %@", frob);
      
      NSString *authURL = [MilkCocoa authURL:frob permission:@"read"];
      NSLog(@"authURL = %@", authURL);
      
      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];

   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}

// 1. run testAuthURL.
// 2. access the authURL obtained, and grant access for the API key.
// 3. run testGetToken test with the frob obtained by testAuthURL
- (void) _testGetToken
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   
   [MilkCocoa getToken:@"e873c0319fe2e6cb30b1595fcf7501207dce7cb0" callback:^(NSError *error, NSString *token) {
      STAssertNil(error, @"should be success");
      STAssertNotNil(token, @"token should be retrieved");
      
      NSLog(@"token = %@", token);
      
      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
   
   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}


@end


@implementation MilkCocoaTest (List)

- (void) testGetList
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   
   [MilkCocoa getList:^(NSError *error, NSArray *lists) {
      STAssertNil(error, @"should be success");
      
      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
   
   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];
}

@end