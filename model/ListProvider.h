/*
 *  ListProvider.h
 *  Milpon
 *
 *  Created by mootoh on 1/26/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@interface ListProvider : NSObject

- (NSArray *) lists;
- (void) add:(NSString *)elm;

- (void) create:(NSDictionary *)params;
- (NSArray *) allLists:(Database *)db;
- (NSString *) nameForListID:(NSNumber *) lid fromDB:(Database *)db;

+ (ListProvider *) sharedListProvider;

@end
