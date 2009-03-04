//
//  DBListProvider.h
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListProvider.h"

@interface ListProvider (DB)
+ (ListProvider *) sharedListProvider;
@end

@class LocalCache;

@interface DBListProvider : ListProvider
{
   LocalCache *local_cache_;
   NSArray *lists_;
}

@end
