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
//- (NSArray *) smartLists;

/**
 * replace all local lists with lists on the web.
 */
- (void) sync;

+ (ListProvider *) sharedListProvider;

@end // ListProvider
