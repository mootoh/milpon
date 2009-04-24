//
//  RTMObject.m
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMObject.h"
#import "logger.h"

@implementation RTMObject

- (id) initByAttributes:(NSDictionary *)attrs;
{
  if (self = [super init]) {
     attrs_ = [[NSMutableDictionary dictionaryWithDictionary:attrs] retain];
  }
  return self;
}

- (void) dealloc
{
  [attrs_ release];
  [super dealloc];
}

- (NSInteger) iD
{
   // retrieve if not cached yet
   return [[attrs_ objectForKey:@"id"] integerValue];
}

- (void) setID:(NSInteger) idd
{
   [attrs_ setObject:[NSNumber numberWithInteger:idd] forKey:@"id"];
   // update DB too
}

- (NSInteger) edit_bits
{
   // retrieve if not cached yet
   return [[attrs_ objectForKey:@"edit_bits"] integerValue];
}

- (void) setEdit_bits:(NSInteger) eb
{
   [attrs_ setObject:[NSNumber numberWithInteger:eb] forKey:@"edit_bits"];
   // update DB too
}

- (void) flagUpEditBits:(NSInteger) flag
{
   NSInteger eb = [[attrs_ objectForKey:@"edit_bits"] integerValue];
   eb |= flag;
   self.edit_bits = eb;
}

- (void) flagDownEditBits:(NSInteger) flag
{
   NSInteger eb = [[attrs_ objectForKey:@"edit_bits"] integerValue];
   eb = eb ^ flag;
   self.edit_bits = eb;
}

@end