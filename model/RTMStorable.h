//
//  RTMStorable.h
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMDatabase;

@interface RTMStorable : NSObject {
   enum {
      SYNCHRONIZED,
      CREATED_OFFLINE,
      MODIFIED
   } state_;

   RTMDatabase *db_;
   NSInteger iD_;
}

- (id) initWithDB:(RTMDatabase *)ddb forID:(NSInteger )iid;

/**
 * create a entity via online.
 */
+ (void) create:(NSDictionary *)params inDB:(RTMDatabase *)db;
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
+ (void) remove:(NSInteger)iid fromDB:(RTMDatabase *)db;

@end
// vim:set ft=objc:
