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

@implementation DBListProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      lists_ = [self lists];
   }
   return self;
}

- (void) dealloc
{
   [lists_ release];
   [super dealloc];
}

// TODO: should cache the result
- (NSArray *) lists:(NSDictionary *)option
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
      RTMList *lst = [[[RTMList alloc]
            initWithID:[dict objectForKey:@"id"]
            forName:[dict objectForKey:@"name"]]
         autorelease];
      [lists addObject:lst];
   }
   [pool release];
   return lists;
}

- (NSArray *) lists
{
   return [self lists:nil];
}

@end

@implementation ListProvider (DB)

static DBListProvider *s_db_list_provider = nil;

+ (ListProvider *) sharedListProvider
{
   if (nil == s_db_list_provider)
      s_db_list_provider = [[DBListProvider alloc] init];
   return s_db_list_provider; 
}

@end // ListProvider (Mock)
