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
#import "logger.h"
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
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (NSArray *) tags
{
   return [self loadTags];
}

- (void) updateTaskSeriesID:(RTMTag *)tag tid:(NSNumber *)tid 
{
   NSDictionary *param = [NSDictionary dictionaryWithObject:tid forKey:@"taskseries_id"];
   NSString *cond = [NSString stringWithFormat:@"id=%d",
      [tag.iD intValue]];
      
   [local_cache_ update:param table:@"tag" condition:cond];
}

- (NSNumber *) find:(NSString *)tag_name
{
   NSArray *query = [NSArray arrayWithObject:@"id"];
   NSDictionary *where = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"name='%@'", tag_name] forKey:@"WHERE"];
   NSArray *results = [local_cache_ select:query from:@"tag" option:where];
   return results.count == 1 ?
      [[results objectAtIndex:0] objectForKey:@"id"] : nil;
}

- (NSInteger)taskCountInTag:(RTMTag *) tag
{
   NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
   NSArray *join_vals = [NSArray arrayWithObjects:@"task", @"task.id=task_tag.task_id", nil];
   NSDictionary *join_dict = [NSDictionary dictionaryWithObjects:join_vals forKeys:join_keys];

   NSArray *tag_keys = [NSArray arrayWithObjects:@"WHERE", @"JOIN", nil];
   NSArray *tag_vals = [NSArray arrayWithObjects:
      [NSString stringWithFormat:@"task_tag.tag_id=%d AND task.completed is NULL", [tag.iD intValue]],
      join_dict,
      nil];
   NSDictionary *cond = [NSDictionary dictionaryWithObjects:tag_vals forKeys:tag_keys];

   NSArray *query = [NSArray arrayWithObject:@"count()"];
   NSArray *counts = [local_cache_ select:query from:@"task_tag" option:cond];
   NSDictionary *count = (NSDictionary *)[counts objectAtIndex:0];
   NSNumber *count_num = [count objectForKey:@"count()"];
   return count_num.integerValue;
}

- (NSArray *) tagsInTask:(NSInteger) task_id
{
   NSMutableArray *tags = [NSMutableArray array];

   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   NSArray *tag_keys = [NSArray arrayWithObjects:@"tag.id", @"tag.name", nil];
   NSArray *join_keys = [NSArray arrayWithObjects:@"table", @"condition", nil];
   NSArray *join_vals = [NSArray arrayWithObjects:@"task_tag", @"tag.id=task_tag.tag_id", nil];
   NSDictionary *join_dict = [NSDictionary dictionaryWithObjects:join_vals forKeys:join_keys];

   NSArray *tag_opt_keys = [NSArray arrayWithObjects:@"WHERE", @"JOIN", nil];
   NSArray *tag_opt_vals = [NSArray arrayWithObjects:[NSString stringWithFormat:@"task_tag.task_id=%d", task_id], join_dict, nil];
   NSDictionary *tag_opts = [NSDictionary dictionaryWithObjects:tag_opt_vals forKeys:tag_opt_keys];

   NSArray *tags_dict = [local_cache_ select:tag_keys from:@"tag" option:tag_opts];
   for (NSDictionary *tag_dict in tags_dict) {
      RTMTag *tag = [[RTMTag alloc]
                     initWithID:[tag_dict objectForKey:@"tag.id"]
                     forName:[tag_dict objectForKey:@"tag.name"]];
      [tags addObject:tag];
      [tag release];
   }

   [pool release];
   return tags;
}

- (void) removeRelationForTask:(NSInteger)task_id
{
   [local_cache_ delete:@"task_tag" condition:[NSString stringWithFormat:@"WHERE task_tag.task_id=%d", task_id]];
}

@end // DBTagProvider

@implementation DBTagProvider (Private)

- (NSArray *) loadTags:(NSDictionary *)option
{
   NSMutableArray *tags = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys  = [NSArray arrayWithObjects:@"tag.id", @"tag.name", nil];
   NSArray *tag_arr = option ?
      [local_cache_ select:keys from:@"tag" option:option] :
      [local_cache_ select:keys from:@"tag"];

   for (NSDictionary *dict in tag_arr) {
      RTMTag *tag = [[RTMTag alloc]
         initWithID:[dict objectForKey:@"tag.id"]
         forName:[dict objectForKey:@"tag.name"]];
      [tags addObject:tag];
      [tag release];
   }
   [pool release];
   return tags;
}


- (NSArray *) loadTags
{
   return [self loadTags:nil];
}

- (void) erase
{
   [local_cache_ delete:@"tag" condition:nil];
}

- (void) remove:(RTMTag *) tag
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@",
      [[tag iD] stringValue]];
   [local_cache_ delete:@"tag" condition:cond];
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
   NSArray *iid = [NSArray arrayWithObject:@"id"];
   NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
   NSArray *ret = [local_cache_ select:iid from:@"tag" option:order];
   NSNumber *tag_id = [[ret objectAtIndex:0] objectForKey:@"id"];
   LOG(@"tag_id = %d", [tag_id intValue]);

   // insert into task_tag table
   NSArray *keys = [NSArray arrayWithObjects:@"task_id", @"tag_id", nil];
   NSArray *vals = [NSArray arrayWithObjects:[params objectForKey:@"task_id"], tag_id, nil];
   NSMutableDictionary *task_tag = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [local_cache_ insert:task_tag into:@"task_tag"];
}

- (void) createRelation:(NSNumber *)task_id tag_id:(NSNumber *)tag_id
{
   NSArray *keys = [NSArray arrayWithObjects:@"task_id", @"tag_id", nil];
   NSArray *vals = [NSArray arrayWithObjects:task_id, tag_id, nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [local_cache_ insert:attrs into:@"task_tag"];
}

- (BOOL) existRelation:(NSNumber *)task_id tag_id:(NSNumber *)tag_id
{
   NSArray *keys = [NSArray arrayWithObjects:@"task_id", @"tag_id", nil];   
   NSArray *ret = [local_cache_ select:keys from:@"task_tag"];
   return ret.count > 0;
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
