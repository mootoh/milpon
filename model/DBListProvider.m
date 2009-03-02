//
//  DBListProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBListProvider.h"
#import "RTMList.h"
#import "Database.h"

@implementation DBListProvider

- (id) init
{
   if (self = [super init]) {
      db_ = [Database sharedDatabase];
      lists_ = [RTMList allLists:db_];
   }
   return self;
}

- (void) dealloc
{
   [lists_ release];
   [super dealloc];
}

- (NSArray *) lists
{
   return lists_;
}

@end


@implementation ListProvider (DB)

static DBListProvider *s_db_list_provider = nil;

+ (ListProvider *) sharedListProvider
{
   if (nil == s_db_list_provider) {
      s_db_list_provider = [[DBListProvider alloc] init];
   }
   return s_db_list_provider; 
}

@end // ListProvider (Mock)