//
//  DBListProvider.h
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListProvider.h"
@class Database;

@interface ListProvider (DB)

+ (ListProvider *) sharedListProvider;

@end

@class RTMDatabase;

@interface DBListProvider : ListProvider
{
   Database *db_;
   NSArray *lists_;
}

- (NSArray *) lists;

@end
