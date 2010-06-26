//
//  RTMAPI+List.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
#import "RTMAPI.h"

@interface RTMAPI (List)

/**
 * call rtm.lists.add
 *
 * @return added list dictionary. if failed, exception will be raised.
 */
- (NSDictionary *) add:(NSString *)name timeline:(NSString *)timeline filter:(NSString *)filter;

/**
 * call rtm.lists.delete
 *
 * @return deletion has been done successfully or not.
 */
- (BOOL) delete:(NSString *)listID timeline:(NSString *)timeline;

/**
 * call rtm.lists.getList
 *
 * @return array of dictionaries containing list properties.
 *         if failed, return nil.
 */
- (NSArray *) getList;

/**
 * call rtm.lists.setName
 *
 * @return renamed list dictionary. if failed, exception will be raised.
 */
- (NSDictionary *) setName:(NSString *)name list:(NSString *)listID timeline:(NSString *)timeline;

/**
 * call rtm.lists.archive
 *
 * @return archive has been done successfully or not.
 */
- (BOOL) archive:(NSString *)listID timeline:(NSString *)timeline;

/**
 * call rtm.lists.unarchive
 *
 * @return archive has been done successfully or not.
 */
- (BOOL) unarchive:(NSString *)listID timeline:(NSString *)timeline;

#if 0
// -------------------------------------------------------------------
// not implemented yet.
//
/**
 * call rtm.lists.setDefaultList
 *
 * won't implement this.
 */
- (void) setDefaultList:(NSString *)list_id;
#endif // 0
@end