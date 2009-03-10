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

- (void) updateTaskSeriesID:(RTMTag *)tag tid:(NSNumber *)tid 
{
   NSDictionary *param = [NSDictionary dictionaryWithObject:tid forKey:@"task_series_id"];
   NSString *cond = [NSString stringWithFormat:@"id=%d",
      [tag.iD intValue]];
      
   [local_cache_ update:param table:@"tag" condition:cond];
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
      [local_cache_ select:dict from:@"tag" option:option] :
      [local_cache_ select:dict from:@"tag"];

   for (NSDictionary *dict in tag_arr) {
      RTMTag *tag = [[RTMTag alloc]
         initWithID:[dict objectForKey:@"id"]
         forName:[dict objectForKey:@"name"]];
      [tags addObject:tag];
      [tag release];
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
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObject:
      [params objectForKey:@"name"] forKey:@"name"];
   if ([params objectForKey:@"iD"]) {
      NSNumber *iD = [NSNumber numberWithInt:[[params objectForKey:@"iD"] intValue]];
      [attrs setObject:iD forKey:@"id"];
   }

   [local_cache_ insert:attrs into:@"tag"];

   // obtain tag_id created
   NSDictionary *iid = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"id"];
   NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
   NSArray *ret = [local_cache_ select:iid from:@"tag" option:order];
   NSNumber *tag_id = [[ret objectAtIndex:0] objectForKey:@"id"];
   NSLog(@"tag_id = %d", [tag_id intValue]);

   // insert into task_tag table
   NSArray *keys = [NSArray arrayWithObjects:@"task_series_id", @"tag_id", nil];
   NSArray *vals = [NSArray arrayWithObjects:[params objectForKey:@"task_series_id"], tag_id, nil];
   NSMutableDictionary *task_tag = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [local_cache_ insert:task_tag into:@"task_tag"];

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
