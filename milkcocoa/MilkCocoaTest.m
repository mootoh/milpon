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
