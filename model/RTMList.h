//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"
@class Database;

@interface RTMList : RTMStorable
{
   NSString *name;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSArray *tasks;

+ (void) create:(NSDictionary *)params inDB:(Database *)db;
+ (NSArray *) allLists:(Database *)db;
+ (NSString *) nameForListID:(NSNumber *) lid fromDB:(Database *)db;

- (id) initByParams:(NSDictionary *)params inDB:(Database *)ddb;
- (NSInteger) taskCount;

@end
// vim:set ft=objc:
