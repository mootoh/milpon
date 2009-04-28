//
//  DBListProvider.h
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListProvider.h"

@class LocalCache;

@interface DBListProvider : ListProvider
{
   LocalCache *local_cache_;
}
@end