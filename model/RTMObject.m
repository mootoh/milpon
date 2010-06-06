//
//  RTMObject.m
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMObject.h"
#import "LocalCache.h"
#import "MPLogger.h"

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
   return [[attrs_ objectForKey:[NSString stringWithFormat:@"%@.edit_bits", [self.class table_name]]] integerValue];
}

- (void) setEdit_bits:(NSInteger) eb
{
   [attrs_ setObject:[NSNumber numberWithInteger:eb] forKey:[NSString stringWithFormat:@"%@.edit_bits", [self.class table_name]]];
   NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:eb] forKey:@"edit_bits"];
   // update DB too
   [[LocalCache sharedLocalCache] update:dict table:[self.class table_name] condition:[NSString stringWithFormat:@"WHERE id=%d", self.iD]];
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

- (BOOL) is_modified
{
   return self.edit_bits != EB_SYNCHRONIZED;
}

- (void) setAttribute:(id) attr forName:(NSString *)name editBits:(NSInteger)eb
{
   NSString *table_name = [self.class table_name];
   NSInteger edit_bits = self.edit_bits | eb;
   attr = attr ? attr : [NSNull null];
   [attrs_ setObject:attr forKey:[NSString stringWithFormat:@"%@.%@", table_name, name]];
   [attrs_ setObject:[NSNumber numberWithInteger:edit_bits] forKey:[NSString stringWithFormat:@"%@.edit_bits", table_name]];

   NSArray *keys = [NSArray arrayWithObjects:name, @"edit_bits", nil];
   NSArray *vals = [NSArray arrayWithObjects:attr , [NSNumber numberWithInteger:edit_bits], nil];
   NSAssert(keys.count == vals.count, @"key / value counts should be equaul");
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", self.iD];

   [[LocalCache sharedLocalCache] update:dict table:table_name condition:where];
}

- (id) attribute:(NSString *)name
{
   id value = [attrs_ objectForKey:[NSString stringWithFormat:@"%@.%@", [self.class table_name], name]];
   return value == [NSNull null] ? nil : value;
}
   
+ (NSString *) table_name
{
   NSAssert(NO, @"not reach here");
   return nil;
}

@end