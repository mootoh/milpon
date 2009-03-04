//
//  LocalCache.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#include <sqlite3.h>

@interface LocalCache : NSObject
{
   sqlite3  *handle_;
   NSString *path_;
}

@property (nonatomic, readonly) sqlite3 *handle_;

- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table option:(NSDictionary *)option;
- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table;

+ (LocalCache *) sharedLocalCache;

@end // LocalCache
