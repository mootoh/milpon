//
//  RTMStorable.h
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMDatabase;

@interface RTMStorable : NSObject
{
   enum
   {
      SYNCHRONIZED,
      CREATED_OFFLINE,
      MODIFIED
   } state;

   RTMDatabase *db;
   NSNumber *iD;
}

@property (nonatomic, retain) NSNumber *iD;


- (id) initByID:(NSNumber *)iid inDB:(RTMDatabase *)ddb;

/**
 * create a entity via online.
 */
+ (void) createAtOnline:(NSDictionary *)params inDB:(RTMDatabase *)db;
/**
 * create a entity at offline.
 */
+ (void) createAtOffline:(NSDictionary *)params inDB:(RTMDatabase *)db;
/**
 * erase all entities.
 */
+ (void) erase:(RTMDatabase *)db;
/**
 * remove a entity.
 */
+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db;

@end
// vim:set ft=objc:
