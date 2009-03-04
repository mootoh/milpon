/*
 *  ListProvider.h
 *  Milpon
 *
 *  Created by mootoh on 1/26/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMList;

@interface ListProvider : NSObject

- (NSArray *) lists;
- (void) add:(NSString *)elm;
- (void) sync;

- (void) create:(NSDictionary *)params;
- (NSString *) nameForListID:(NSNumber *) lid;
- (NSArray *) tasksInList:(RTMList *)list;

+ (ListProvider *) sharedListProvider;

@end
