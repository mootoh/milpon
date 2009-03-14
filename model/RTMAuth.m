//
//  RTMAuth.m
//  Milpon
//
//  Created by mootoh on 9/5/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAuth.h"
#import "PrivateInfo.h"

@implementation RTMAuth

@synthesize api_key, shared_secret, frob, token;

// set initial, default value
- (id) init
{
  if (self = [super init]) {
     self.api_key = API_KEY;
     self.shared_secret = SHARED_SECRET;
#ifdef LOCAL_DEBUG
     self.frob  = FROB;
     self.token = TOKEN;
#else // LOCAL_DEBUG
     frob = nil;
     token = nil;
#endif // LOCAL_DEBUG
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
  self.api_key = API_KEY;
  self.shared_secret = SHARED_SECRET;
  self.frob = [coder decodeObjectForKey:@"frob"];
#ifdef LOCAL_DEBUG
  self.token = TOKEN;
#else // LOCAL_DEBUG
  self.token = [coder decodeObjectForKey:@"token"];
#endif // LOCAL_DEBUG

  return self;
}

- (void) dealloc
{
  [api_key release];
  [shared_secret release];
  if (frob) [frob release];
  if (token) [token release];
  [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
   if (frob) [encoder encodeObject:frob forKey:@"frob"];
   [encoder encodeObject:token forKey:@"token"];
}

@end
