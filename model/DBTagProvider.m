//
//  DBTagProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBTagProvider.h"
#import "RTMTag.h"
#import "LocalCache.h"
//#import "RTMAPITag.h"

@interface DBTagProvider (Private);
- (NSArray *) loadTags:(NSDictionary *)option;
- (NSArray *) loadTags;
@end // DBTagProvider (Private)

@implementation DBTagProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      dirty_ = NO;
   }
   return self;
}

- (void) dealloc
{
   if (tags_) [tags_ release];
   [super dealloc];
}

- (NSArray *) tags
{
   if (dirty_ || ! tags_) {
      [self loadTags];
      dirty_ = NO;
   }
   return tags_;
}

#if 0
- (void) sync
{
   [self erase];

   RTMAPITag *api_tag = [[RTMAPITag alloc] init];
   NSArray *tags = [api_tag getTag];
   [api_tag release];

   for (NSDictionary *tag in tags)
      [self create:tag];

   // TODO : broadcast the tags are no longer valid.
   [tags_ release];
   [self loadTags];
}
#endif // 0
@end // DBTagProvider

@implementation DBTagProvider (Private)

- (NSArray *) loadTags:(NSDictionary *)option
{
   NSMutableArray *tags = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];

   NSArray *tag_arr = option ?
      [local_cache_ select:dict from:@"tag"] :
      [local_cache_ select:dict from:@"tag" option:option];

   for (NSDictionary *dict in tag_arr) {
      RTMTag *lst = [[RTMTag alloc]
         initWithID:[dict objectForKey:@"id"]
         forName:[dict objectForKey:@"name"]];
      [tags addObject:lst];
      [lst release];
   }
   [pool release];

   if (tags_)
      [tags_ release];
   tags_ = [tags retain];
   return tags;
}


- (NSArray *) loadTags
{
   return [self loadTags:nil];
}

- (void) erase
{
   [local_cache_ delete:@"tag" condition:nil];
   dirty_ = YES;
}

- (void) remove:(RTMTag *) tag
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@",
      [[tag iD] stringValue]];
   [local_cache_ delete:@"tag" condition:cond];
   dirty_ = YES;
}

- (void) create:(NSDictionary *)params
{
   NSString *name = [params objectForKey:@"name"];
   NSMutableDictionary *attrs = [NSDictionary dictionaryWithObject:name forKey:@"name"];

   if ([params objectForKey:@"iD"]) {
      NSNumber *iD = [NSNumber numberWithInt:[[params objectForKey:@"iD"] intValue]];
      [attrs setObject:iD forKey:@"id"];
   }

   [local_cache_ insert:attrs into:@"tag"];
   dirty_ = YES;
}

- (NSString *)nameForTagID:(NSNumber *)tag_id {
   for (RTMTag *lst in [self tags]) {
      if ([lst.iD isEqualToNumber:tag_id])
         return lst.name;
   }
   NSAssert(NO, @"not reach here");
   return nil;
}


@end // DBTagProvider (Private)

@implementation TagProvider (DB)

static DBTagProvider *s_db_tag_provider = nil;

+ (TagProvider *) sharedTagProvider
{
   if (nil == s_db_tag_provider)
      s_db_tag_provider = [[DBTagProvider alloc] init];
   return s_db_tag_provider; 
}

@end // TagProvider (Mock)
