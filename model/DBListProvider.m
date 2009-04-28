//
//  DBListProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBListProvider.h"
#import "RTMList.h"
#import "LocalCache.h"

@interface DBListProvider (Private);
- (NSArray *) loadLists:(NSDictionary *)option;
- (NSArray *) loadLists;
@end // DBListProvider (Private)

@implementation DBListProvider

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

- (NSArray *) lists
{
   return [self loadLists];
}

/*
- (void) sync
{
   [self erase];

   RTMAPIList *api_list = [[RTMAPIList alloc] init];
   NSArray *lists = [api_list getList];
   [api_list release];

   for (NSDictionary *list in lists)
      [self create:list];

   // TODO : broadcast the lists are no longer valid.
   [lists_ release];
   [self loadLists];
}
*/
/*
- (NSInteger)taskCountInList:(RTMList *) list
{
   NSDictionary *cond = [NSDictionary dictionaryWithObject:
      [NSString stringWithFormat:@"list_id=%d AND completed is NULL", [list.iD intValue]]
      forKey:@"WHERE"];

   NSDictionary *query = [NSDictionary dictionaryWithObject:[NSNumber class] forKey:@"count()"];
   NSArray *counts = [local_cache_ select:query from:@"task" option:cond];
   NSDictionary *count = (NSDictionary *)[counts objectAtIndex:0];
   NSNumber *count_num = [count objectForKey:@"count()"];
   return count_num.integerValue;
}
*/

@end // DBListProvider

@implementation DBListProvider (Private)

- (NSArray *) loadLists:(NSDictionary *)option
{
   NSMutableArray *lists = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];

   NSArray *list_arr = option ?
      [local_cache_ select:dict from:@"list" option:option] :
      [local_cache_ select:dict from:@"list"];

   for (NSDictionary *attrs in list_arr) {
      RTMList *lst = [[RTMList alloc] initByAttributes:attrs];
      [lists addObject:lst];
      [lst release];
   }
   [pool release];

   return lists;
}


- (NSArray *) loadLists
{
   NSDictionary *opts = [NSDictionary dictionaryWithObject:@"filter is NULL" forKey:@"WHERE"];
   return [self loadLists:opts];
}
/*
- (void) erase
{
   [local_cache_ delete:@"list" condition:nil];
}

- (void) remove:(RTMList *) list
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@",
      [[list iD] stringValue]];
   [local_cache_ delete:@"list" condition:cond];
}

- (void) create:(NSDictionary *)params
{
   NSString *name = [params objectForKey:@"name"];
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObject:name forKey:@"name"];

   if ([params objectForKey:@"id"])
      [attrs setObject:[params objectForKey:@"id"] forKey:@"id"];

   if ([params objectForKey:@"filter"])
      [attrs setObject:[params objectForKey:@"filter"] forKey:@"filter"];

   [local_cache_ insert:attrs into:@"list"];
}

- (NSString *)nameForListID:(NSNumber *)list_id {
   for (RTMList *lst in [self lists]) {
      if ([lst.iD isEqualToNumber:list_id])
         return lst.name;
   }
   NSAssert(NO, @"not reach here");
   return nil;
}
*/
@end // DBListProvider (Private)

@implementation ListProvider (DB)

static DBListProvider *s_db_list_provider = nil;

+ (ListProvider *) sharedListProvider
{
   if (nil == s_db_list_provider)
      s_db_list_provider = [[DBListProvider alloc] init];
   return s_db_list_provider; 
}

@end // ListProvider (Mock)
