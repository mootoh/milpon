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
#import "RTMAPIList.h"

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
   NSDictionary *option = [NSDictionary dictionaryWithObject:@"list.filter is NULL" forKey:@"WHERE"]; // skip Smart List
	return [self loadLists:option];
}

- (void) sync
{
   [self erase];

   RTMAPIList *api_list = [[RTMAPIList alloc] init];
   NSArray *lists = [api_list getList];
   [api_list release];

   for (NSDictionary *list in lists)
      [self create:list];
   
   NSDictionary *option = [NSDictionary dictionaryWithObject:@"list.filter is NULL" forKey:@"WHERE"]; // skip Smart List
   [self loadLists:option];
}
@end // DBListProvider

@implementation DBListProvider (Private)

- (NSArray *) loadLists:(NSDictionary *)option
{
   NSMutableArray *lists = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys = [NSArray arrayWithObjects:@"list.id", @"list.name", @"list.filter", nil];

   NSArray *list_arr = option ?
      [local_cache_ select:keys from:@"list" option:option] :
      [local_cache_ select:keys from:@"list"];

   for (NSDictionary *attrs in list_arr) {
      RTMList *lst = [[[RTMList alloc] initByAttributes:attrs] autorelease];
      [lists addObject:lst];
   }
   [pool release];

   return lists;
}

- (NSArray *) loadLists
{
//   NSDictionary *opts = [NSDictionary dictionaryWithObject:@"filter is NULL" forKey:@"WHERE"];
//   return [self loadLists:opts];
   return [self loadLists:nil];
}

- (void) erase
{
   [local_cache_ delete:@"list" condition:nil];
}

- (void) remove:(RTMList *) list
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %d", list.iD];
   [local_cache_ delete:@"list" condition:cond];
}

/**
  * params should have (id, filter*)
  */
- (void) create:(NSDictionary *)params
{
   NSString *name = [params objectForKey:@"name"];
   NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObject:name forKey:@"name"];

   NSAssert([params objectForKey:@"id"], @"should have id");
   [attrs setObject:[params objectForKey:@"id"] forKey:@"id"];

   if ([params objectForKey:@"filter"])
      [attrs setObject:[params objectForKey:@"filter"] forKey:@"filter"];

   [local_cache_ insert:attrs into:@"list"];
}

- (NSString *)nameForListID:(NSNumber *)list_id {
   for (RTMList *lst in [self lists]) {
      if (lst.iD == [list_id integerValue])
         return lst.name;
   }
   NSAssert(NO, @"not reach here");
   return nil;
}
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
