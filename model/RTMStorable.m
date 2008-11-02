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
    db_ = [ddb retain];
    iD_ = iid;
  }
  return self;
}

- (void) dealloc {
  [db_ release];
  [super dealloc];
}

+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db {
}

+ (void) erase:(RTMDatabase *)db {
}

+ (void) remove:(NSInteger)iid fromDB:(RTMDatabase *)db {
}

@end
