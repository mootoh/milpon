//
//  MilkCocoaTest
//  Milpon
//
//  Created by Motohiro Takayama on 2/21/11.
//  Copyright 2011 deadbeaf.org. All rights reserved.
//

#import "MilkCocoaTest.h"
#import "MilkCocoa.h"

@implementation MilkCocoaTest

- (void) testEcho
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   [MCRequest echo:^(NSError *error, NSDictionary *result) {
      NSLog(@"echoed.");

      STAssertNil(error, @"should be succeeded");

      NSString *method = [result objectForKey:@"method"];
      STAssertTrue([method isEqualToString:@"rtm.test.echo"], [NSString stringWithFormat:@"method check, received:", method]);

      NSString *api_key = [result objectForKey:@"api_key"];
      STAssertNotNil(result, @"should be passed a valid api_key");

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
