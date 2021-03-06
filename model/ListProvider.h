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
 * create List in DB, called from rtm.lists.getList callback
 */
- (void) create:(NSDictionary *)params;
- (void) remove:(RTMList *) list;
- (void) erase; // remove all lists from DB.
- (NSString *)nameForListID:(NSNumber *)list_id;
- (RTMList *) inboxList;

/**
 * replace all local lists with lists on the web.
 */
- (void) sync;

+ (ListProvider *) sharedListProvider;

@end // ListProvider
