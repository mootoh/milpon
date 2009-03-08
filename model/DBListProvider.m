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
      dirty_ = NO;
   }
   return self;
}

- (void) dealloc
{
   if (lists_) [lists_ release];
   [super dealloc];
}

- (NSArray *) lists
{
   if (dirty_ || ! lists_) {
      NSLog(@"init lists");
      [self loadLists];
      dirty_ = NO;
   }
   NSLog(@"lists initilaized");
   return lists_;
}

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
      [local_cache_ select:dict from:@"list"] :
      [local_cache_ select:dict from:@"list" option:option];

   for (NSDictionary *dict in list_arr) {
      RTMList *lst = [[RTMList alloc]
         initWithID:[dict objectForKey:@"id"]
         forName:[dict objectForKey:@"name"]];
      [lists addObject:lst];
      [lst release];
   }
   [pool release];

   if (lists_)
      [lists_ release];
   lists_ = [lists retain];
   return lists;
}


- (NSArray *) loadLists
{
   return [self loadLists:nil];
}

- (void) erase
{
   [local_cache_ delete:@"list" condition:nil];
   dirty_ = YES;
}

- (void) remove:(RTMList *) list
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %@",
      [[list iD] stringValue]];
   [local_cache_ delete:@"list" condition:cond];
   dirty_ = YES;
}

- (void) create:(NSDictionary *)params
{
   NSNumber *iD = [NSNumber numberWithInt:[[params objectForKey:@"iD"] intValue]];

   NSArray *keys = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *vals = [NSArray arrayWithObjects:iD, [params objectForKey:@"name"], nil];
   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [local_cache_ insert:attrs into:@"list"];
   dirty_ = YES;
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
