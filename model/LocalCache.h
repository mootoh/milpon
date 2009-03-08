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

/**
 * SQL SELECT.
 *
 * @param [in] dict specify columns to be selected as {name => type} pairs.
 * @param [in] table table to be selected from.
 * @param option [in] other options like ORDER, HWERE, etc...
 */
- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table option:(NSDictionary *)option;

/**
 * shorthand of select:from:option (no option)
 */
- (NSArray *) select:(NSDictionary *)dict from:(NSString *)table;

/**
 * SQL INSERT.
 */
- (void) insert:(NSDictionary *)dict into:(NSString *)table;

/**
 * SQL UPDATE.
 */
- (void) update:(NSDictionary *)dict table:(NSString *)table condition:(NSString *)cond;

/**
 * SQL DELETE.
 */
- (void) delete:(NSString *)table condition:(NSString *)cond;

- (NSString *) lastSync;

/**
 * get singleton instance.
 */
+ (LocalCache *) sharedLocalCache;

@end // LocalCache
