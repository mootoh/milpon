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
   return [[attrs_ objectForKey:[NSString stringWithFormat:@"%@.id", [self.class table_name]]] integerValue];
}

- (void) setID:(NSInteger) idd
{
   [attrs_ setObject:[NSNumber numberWithInteger:idd] forKey:[NSString stringWithFormat:@"%@.id", [self.class table_name]]];
   // update DB too
}

- (NSInteger) edit_bits
{
   // retrieve if not cached yet
   return [[attrs_ objectForKey:[NSString stringWithFormat:@"%@.edit_bits", [self.class table_name]]] integerValue];
}

- (void) setEdit_bits:(NSInteger) eb
{
   [attrs_ setObject:[NSNumber numberWithInteger:eb] forKey:[NSString stringWithFormat:@"%@.edit_bits", [self.class table_name]]];
   // update DB too
}

- (void) flagUpEditBits:(NSInteger) flag
{
   NSInteger eb = self.edit_bits;
   eb |= flag;
   self.edit_bits = eb;
}

- (void) flagDownEditBits:(NSInteger) flag
{
   NSInteger eb = self.edit_bits;
   eb = eb ^ flag;
   self.edit_bits = eb;
}

+ (NSString *) table_name
{
   NSAssert(NO, @"not reach here");
   return nil;
}

@end