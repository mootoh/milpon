//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@interface RTMList : RTMStorable
{
  NSString *name;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSArray *tasks;

+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db;
+ (NSArray *) allLists:(RTMDatabase *)db;
+ (NSString *) nameForListID:(NSNumber *) lid fromDB:(RTMDatabase *)db;

- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb;
- (NSInteger) taskCount;

@end
// vim:set ft=objc:
