/*
 *  ListProvider.h
 *  Milpon
 *
 *  Created by mootoh on 1/26/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@interface ListProvider

- (NSArray *) lists;

@end

(ListProvider *) sharedListProvider;
