//
//  RTMStorable.m
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@implementation RTMStorable

- (id) initWithDB:(RTMDatabase *)ddb forID:(NSInteger )iid {
  if (self = [super init]) {
    db = [ddb retain];
    iD = iid;
  }
  return self;
}

- (void) dealloc {
  [db release];
  [super dealloc];
}

+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db {
}

+ (void) erase:(RTMDatabase *)db {
}

+ (void) remove:(NSInteger)iid fromDB:(RTMDatabase *)db {
}

@end
