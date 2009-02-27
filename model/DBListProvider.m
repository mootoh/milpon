//
//  DBListProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBListProvider.h"


@implementation DBListProvider

- (id) init
{
   if (self = [super init]) {
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (NSArray *) lists
{
   return nil;
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