//
//  RTMObject.h
//  Milpon
//
//  Created by mootoh on 10/9/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
//
//  synchronized object between DB and Web.
//    - attribute modification updates DB immediately
//    - sync to Web is done explicitly
//
enum edit_bits_t {
   EB_SYNCHRONIZED    = 0,
   EB_CREATED_OFFLINE = 1 << 0
};

@interface RTMObject : NSObject
{
   NSMutableDictionary *attrs_;
}

@property (nonatomic) NSInteger iD;
@property (nonatomic) NSInteger edit_bits;

- (id) initByAttributes:(NSDictionary *)attrs;
- (void) flagUpEditBits:(NSInteger) flag;
- (void) flagDownEditBits:(NSInteger) flag;
- (BOOL) is_modified;

- (void) setAttribute:(id) attr forName:(NSString *)name editBits:(NSInteger)eb;
- (id) attribute:(NSString *)name;

+ (NSString *)table_name;

/**
 * create a entity via online.
 */
//+ (void) createAtOnline:(NSDictionary *)params inDB:(RTMDatabase *)db;
/**
 * create a entity at offline.
 */
//+ (void) createAtOffline:(NSDictionary *)params inDB:(RTMDatabase *)db;
/**
 * erase all entities.
 */
//+ (void) erase:(RTMDatabase *)db;
/**
 * remove a entity.
 */
//+ (void) remove:(NSNumber *)iid fromDB:(RTMDatabase *)db;

@end