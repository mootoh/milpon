//
//  DBTagProvider.h
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagProvider.h"

@class LocalCache;

@interface DBTagProvider : TagProvider
{
   LocalCache *local_cache_;
}
@end

@interface TagProvider (DB)
+ (TagProvider *) sharedTagProvider;
@end

