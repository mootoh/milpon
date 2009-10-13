//
//  ListProvider.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListProvider.h"

@implementation ListProvider

- (NSArray *) lists
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (void) create:(NSDictionary *)params
{
   NSAssert(NO, @"not reach here");
}

- (NSString *) nameForListID:(NSNumber *) lid
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) tasksInList:(RTMList *)list
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (void) sync
{
   NSAssert(NO, @"not reach here");
}

- (void) erase
{
   NSAssert(NO, @"not reach here");
}

- (void) remove:(RTMList *)list
{
   NSAssert(NO, @"not reach here");
}

- (RTMList *) inboxList
{
   NSAssert(NO, @"not reach here");
   return nil;
}

+ (ListProvider *) sharedListProvider
{
   NSAssert(NO, @"not reach here");
   return nil;
}
   
@end
