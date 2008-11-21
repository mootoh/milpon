//
//  RTMStorable.m
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"
#import "logger.h"

@implementation RTMStorable

@synthesize iD;

- (id) initByID:(NSNumber *)iid inDB:(RTMDatabase *)ddb
{
  if (self = [super init]) {
    db = ddb;
    iD = [iid retain];
  }
  return self;
}

- (void) dealloc
{
  [iD release];
  [super dealloc];
}

+ (void) createAtOnline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
}

+ (void) createAtOffline:(NSDictionary *)params inDB:(RTMDatabase *)db
{
}

+ (void) erase:(RTMDatabase *)db
{
}

+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db;
{
}

- (id) retain
{
   LOG(@"RTMStorable retaining %d", [self retainCount]);
   return [super retain];
}

- (void) release
{
   LOG(@"RTMStorable releasing %d", [self retainCount]);
   [super release];
}

@end
