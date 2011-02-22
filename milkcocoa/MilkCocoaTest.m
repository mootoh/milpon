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

- (void) testEcho
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MCRequest echo:^(NSError *error, NSDictionary *result) {
      NSLog(@"echoed.");

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

- (void) _testGetList
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MCRequest getList:^(NSError *error, NSArray *lists) {
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

- (void) _testCheckToken
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MCRequest checkToken:RTM_TOKEN_R callback:^(NSError *error, NSArray *lists) {
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

- (void) testGetFrob
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MCRequest getFrob:^(NSError *error, id result) {
      STAssertNil(error, @"should be success");

      NSString *frob = [result objectForKey:@"frob"];
#if 0
      if (frob == nil) {
         NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"cannot find a frob in the response" forKey:NSLocalizedDescriptionKey];
         error = [NSError errorWithDomain:k_MC_ERROR_DOMAIN
                                     code:1
                                 userInfo:userInfo];
         callback(error, nil);
         return;
      }
#endif // 0

      STAssertNotNil(frob, @"frob should be otained.");
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

@end
