//
//  TagProvider.m
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagProvider.h"

@implementation TagProvider

- (NSArray *) tags
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (void) create:(NSDictionary *)params
{
   NSAssert(NO, @"not reach here");
}

- (void) createRelation:(NSNumber *)task_id tag_id:(NSNumber *)tag_id
{
   NSAssert(NO, @"not reach here");
}

- (NSString *) nameForTagID:(NSNumber *) lid
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSArray *) tasksInTag:(RTMTag *)tag
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

- (void) remove:(RTMTag *)tag
{
   NSAssert(NO, @"not reach here");
}

- (void) updateTaskSeriesID:(RTMTag *)tag tid:(NSNumber *)tid;
{
   NSAssert(NO, @"not reach here");
}

+ (TagProvider *) sharedTagProvider
{
   NSAssert(NO, @"not reach here");
   return nil;
}
   
@end

